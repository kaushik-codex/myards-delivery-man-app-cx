import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_confirmation_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/home/widgets/location_access_dialog.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class OnlineStatusToggleWidget extends StatelessWidget {
  const OnlineStatusToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      return GetBuilder<RideController>(builder: (rideController) {
        return GetBuilder<OrderController>(builder: (orderController) {
          if (profileController.profileModel == null) {
            return const SizedBox();
          }

          final bool isOnline = profileController.profileModel!.active == 1;

          return InkWell(
            onTap: () => _handleToggle(context, profileController, rideController, orderController),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 80,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isOnline ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: isOnline ? Alignment.centerLeft : Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: isOnline ? 6 : 0,
                        right: isOnline ? 0 : 6,
                      ),
                      child: Text(
                        isOnline ? 'online'.tr : 'offline'.tr,
                        style: robotoMedium.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),

                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      });
    });
  }

  void _handleToggle(
    BuildContext context,
    ProfileController profileController,
    RideController rideController,
    OrderController orderController,
  ) async {
    if (profileController.profileModel == null) return;

    final bool isOnline = profileController.profileModel!.active == 1;
    final bool targetStatus = !isOnline;
    final bool isRideActive = AppConstants.appMode == AppMode.ride;
    final bool haveRunningRide = rideController.lastRideDetails != null &&
        rideController.lastRideDetails!.isNotEmpty &&
        rideController.lastRideDetails![0].currentStatus != 'completed' &&
        rideController.lastRideDetails![0].currentStatus != 'cancelled';

    if (!isRideActive && !targetStatus && (orderController.currentOrderList?.isNotEmpty ?? false)) {
      showCustomBottomSheet(
        child: CustomConfirmationBottomSheet(
          title: 'you_cant_go_offline'.tr,
          description: 'you_can_not_go_offline_now'.tr,
          buttonWidget: Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: CustomButtonWidget(
              width: 150,
              onPressed: () => Get.back(),
              buttonText: 'okay'.tr,
            ),
          ),
        ),
      );
    } else if (isRideActive && !targetStatus && haveRunningRide) {
      showCustomBottomSheet(
        child: CustomConfirmationBottomSheet(
          title: 'you_cant_go_offline'.tr,
          description: 'you_can_not_go_offline_now_for_ride'.tr,
          buttonWidget: Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: CustomButtonWidget(
              width: 150,
              onPressed: () => Get.back(),
              buttonText: 'okay'.tr,
            ),
          ),
        ),
      );
    } else {
      if (!targetStatus) {
        showCustomBottomSheet(
          child: CustomConfirmationBottomSheet(
            title: 'go_offline'.tr,
            description: 'are_you_sure_to_offline'.tr,
            image: Images.dmOfflineIcon,
            buttonWidget: Padding(
              padding: const EdgeInsets.only(
                left: 40,
                right: 40,
                bottom: 20,
                top: 10,
              ),
              child: Row(children: [
                Expanded(
                  child: CustomButtonWidget(
                    onPressed: () {
                      profileController.updateActiveStatus();
                    },
                    buttonText: 'yes_proceed'.tr,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: CustomButtonWidget(
                    onPressed: () => Get.back(),
                    buttonText: 'cancel'.tr,
                    backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    fontColor: Theme.of(context).disabledColor,
                    isBorder: true,
                  ),
                ),
              ]),
            ),
          ),
        );
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever ||
            (GetPlatform.isIOS ? false : permission == LocationPermission.whileInUse)) {
          _checkPermission(() => profileController.updateActiveStatus());
        } else {
          profileController.updateActiveStatus();
        }
      }
    }
  }

  void _checkPermission(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();

    while (Get.isDialogOpen == true) {
      Get.back();
    }

    if (permission == LocationPermission.denied) {
      Get.dialog(LocationAccessDialog(onConfirm: () async {
        Get.back();
        final perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.deniedForever) await Geolocator.openAppSettings();
        if (GetPlatform.isAndroid) _checkPermission(callback);
      }));
    } else if (permission == LocationPermission.deniedForever ||
        (GetPlatform.isIOS ? false : permission == LocationPermission.whileInUse)) {
      Get.dialog(LocationAccessDialog(onConfirm: () async {
        Get.back();
        await Geolocator.openAppSettings();
        Future.delayed(const Duration(seconds: 3), () {
          if (GetPlatform.isAndroid) _checkPermission(callback);
        });
      }));
    } else {
      callback();
    }
  }
}
