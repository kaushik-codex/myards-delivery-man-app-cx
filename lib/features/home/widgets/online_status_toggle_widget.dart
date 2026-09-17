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

import 'package:sixam_mart_delivery/util/color_resources.dart';

class OnlineStatusToggleWidget extends StatefulWidget {
  final bool isFloatingCapsule;
  const OnlineStatusToggleWidget({super.key, this.isFloatingCapsule = false});

  @override
  State<OnlineStatusToggleWidget> createState() => _OnlineStatusToggleWidgetState();
}

class _OnlineStatusToggleWidgetState extends State<OnlineStatusToggleWidget> with SingleTickerProviderStateMixin {
  static bool _isSyncing = false;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _breathingAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _breathingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return GetBuilder<ProfileController>(builder: (profileController) {
      return GetBuilder<RideController>(builder: (rideController) {
        return GetBuilder<OrderController>(builder: (orderController) {
          if (profileController.profileModel == null) {
            return const SizedBox();
          }

          final bool isOnline = profileController.profileModel!.active == 1;
          final bool isLoading = profileController.isActiveStatusLoading;

          if (widget.isFloatingCapsule) {
            return _buildFloatingCapsule(
              context: context,
              isDark: isDark,
              isOnline: isOnline,
              isLoading: isLoading,
              profileController: profileController,
              rideController: rideController,
              orderController: orderController,
            );
          }

          return _buildLegacyToggle(
            context: context,
            isOnline: isOnline,
            isLoading: isLoading,
            profileController: profileController,
            rideController: rideController,
            orderController: orderController,
          );
        });
      });
    });
  }

  Widget _buildFloatingCapsule({
    required BuildContext context,
    required bool isDark,
    required bool isOnline,
    required bool isLoading,
    required ProfileController profileController,
    required RideController rideController,
    required OrderController orderController,
  }) {
    final Color capsuleBg = isOnline
        ? (isDark ? ColorResources.redDeep : ColorResources.myardsRed)
        : Theme.of(context).cardColor;

    final Color borderColor = isOnline
        ? (isDark ? ColorResources.redDeep : ColorResources.myardsRed)
        : (isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine);

    final Widget capsuleBody = Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: capsuleBg,
        borderRadius: BorderRadius.circular(500),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x4D000000) : const Color(0x1F1B211D),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isOnline ? 'online'.tr.toUpperCase() : 'offline'.tr.toUpperCase(),
            style: TextStyle(
              color: isOnline
                  ? Colors.white
                  : (isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 24,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isOnline
                  ? Colors.black.withValues(alpha: 0.22)
                  : (isDark ? ColorResources.nightSurfaceRaised : ColorResources.canvasMist),
              borderRadius: BorderRadius.circular(500),
              border: isOnline
                  ? null
                  : Border.all(
                      color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                      width: 0.8,
                    ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.white
                      : (isDark ? ColorResources.nightInk : ColorResources.inkCharcoal),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                  ],
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOnline ? ColorResources.myardsRed : Colors.white,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () => _handleToggle(context, profileController, rideController, orderController),
        borderRadius: BorderRadius.circular(500),
        child: (isOnline && !isLoading)
            ? AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) => Opacity(
                  opacity: _breathingAnimation.value,
                  child: child,
                ),
                child: capsuleBody,
              )
            : capsuleBody,
      ),
    );
  }

  Widget _buildLegacyToggle({
    required BuildContext context,
    required bool isOnline,
    required bool isLoading,
    required ProfileController profileController,
    required RideController rideController,
    required OrderController orderController,
  }) {
    return InkWell(
      onTap: isLoading ? null : () => _handleToggle(context, profileController, rideController, orderController),
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
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOnline ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleToggle(
    BuildContext context,
    ProfileController profileController,
    RideController rideController,
    OrderController orderController,
  ) async {
    if (profileController.profileModel == null || profileController.isActiveStatusLoading || _isSyncing) return;
    _isSyncing = true;
    try {
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
    } finally {
      _isSyncing = false;
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
