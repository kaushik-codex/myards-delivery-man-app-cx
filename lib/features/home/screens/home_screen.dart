import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/home/widgets/active_order_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/active_ride_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/cash_in_hand_card_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/home_earning_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/order_count_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/referal_card_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/ride_activity_view.dart';
import 'package:sixam_mart_delivery/features/home/widgets/ride_floating_button_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/ride_order_count_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/vehicle_add_widget.dart';
import 'package:sixam_mart_delivery/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/trip/controllers/trip_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'dart:convert';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/helper/floating_overlay_helper.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToOrders, this.onNavigateToProfile});
  final Function()? onNavigateToOrders;
  final Function()? onNavigateToProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late final AppLifecycleListener _listener;
  bool _isNotificationPermissionGranted = true;
  bool _isBatteryOptimizationGranted = true;
  bool isRideActive = AppConstants.appMode == AppMode.ride;

  @override
  void initState() {
    super.initState();

    _checkSystemNotification();

    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );

    _loadData();

    Future.delayed(const Duration(milliseconds: 200), () {
      checkPermission();
    });
  }

  Future<void> _loadData() async {

    Get.find<OrderController>().getIgnoreList();
    Get.find<OrderController>().removeFromIgnoreList();

    if(isRideActive){
      Get.find<RideController>().getLastRideDetail();
      Get.find<TripController>().getDailyLog();
      Get.find<TripController>().rideCancellationReasonList();
      Get.find<RideController>().ongoingTripList();
      Get.find<ProfileController>().getProfileLevelInfo();
      await Get.find<TripController>().getTripList(1);
    }else{
      await Get.find<OrderController>().getRunningOrders(1, willUpdate: false);
    }
    await Get.find<ProfileController>().getProfile();
    await Get.find<NotificationController>().getNotificationList();
  }

  Future<void> _checkSystemNotification() async {
    if(await Permission.notification.status.isDenied || await Permission.notification.status.isPermanentlyDenied) {
      await Get.find<AuthController>().setNotificationActive(false);
    }
  }

  // Listen to the app lifecycle state changes
  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        checkPermission();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  Future<void> checkPermission() async {
    var notificationStatus = await Permission.notification.status;
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    if(notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      setState(() {
        _isNotificationPermissionGranted = false;
        _isBatteryOptimizationGranted = true;
      });

      await Get.find<AuthController>().setNotificationActive(!notificationStatus.isDenied);

    } else if(batteryStatus.isDenied) {
      setState(() {
        _isBatteryOptimizationGranted = false;
        _isNotificationPermissionGranted = true;
      });
    } else {
      setState(() {
        _isNotificationPermissionGranted = true;
        _isBatteryOptimizationGranted = true;
      });
      Get.find<ProfileController>().setBackgroundNotificationActive(true);
      checkAndRequestOverlayPermission();
    }

    if(batteryStatus.isDenied) {
      Get.find<ProfileController>().setBackgroundNotificationActive(false);
    }
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      checkPermission();
      return;
    } else {
      await openAppSettings();
    }

    checkPermission();
  }

  ///Added permission request for SYSTEM_ALERT_WINDOW for floating order alerts
  Future<void> checkAndRequestOverlayPermission() async {
    bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!isGranted) {
      Get.dialog(
        ConfirmationDialogWidget(
          icon: Images.warning,
          title: 'Floating Order Alerts',
          description: 'Allow ${AppConstants.appName} to display floating alerts over other apps so you never miss a new delivery request.',
          onYesPressed: () async {
            Get.back();
            await FlutterOverlayWindow.requestPermission();
          },
        ),
      );
    }
  }

  void _testFloatingOverlay() async {
    if (!kDebugMode) return;
    FloatingOverlayHelper.initListener();

    bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!isGranted) {
      await FlutterOverlayWindow.requestPermission();
      return;
    }

    const int mockId = FloatingOverlayHelper.mockOrderId;
    final OrderModel mockOrder = FloatingOverlayHelper.createMockOrderModel();

    // Inject mock order into OrderController in-memory for testing
    if (Get.isRegistered<OrderController>()) {
      final oc = Get.find<OrderController>();
      oc.latestOrderList ??= [];
      // Remove any prior mock instance to support clean repeated dispatch
      oc.latestOrderList!.removeWhere((o) => o.id == mockId);
      oc.latestOrderList!.insert(0, mockOrder);
      oc.update();
    }

    showCustomSnackBar('Mock order dispatched! Minimize the app if desired, overlay appearing in 2 seconds...', isError: false);

    Future.delayed(const Duration(seconds: 2), () async {
      try {
        if (await FlutterOverlayWindow.isActive()) {
          await FlutterOverlayWindow.closeOverlay();
          await Future.delayed(const Duration(milliseconds: 300));
        }

        await FlutterOverlayWindow.showOverlay(
          enableDrag: false,
          overlayTitle: "New Order Request",
          overlayContent: 'Order #$mockId',
          flag: OverlayFlag.defaultFlag,
          alignment: OverlayAlignment.center,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.auto,
          height: WindowSize.matchParent,
          width: WindowSize.matchParent,
        );

        print("====> [HomeScreen] FlutterOverlayWindow.showOverlay launched for mock order #$mockId");

        await Future.delayed(const Duration(milliseconds: 500));
        await FlutterOverlayWindow.shareData(jsonEncode({
          'order_id': mockId.toString(),
          'store_name': mockOrder.storeName ?? 'Mock Pizza Hub (Downtown)',
          'order_amount': '₹499',
          'delivery_address': mockOrder.deliveryAddress?.address ?? '742 Evergreen Terrace, Sector 4, Springfield',
          'latitude': mockOrder.deliveryAddress?.latitude ?? '23.8103',
          'longitude': mockOrder.deliveryAddress?.longitude ?? '90.4125',
          'store_lat': mockOrder.storeLat ?? '23.8150',
          'store_lng': mockOrder.storeLng ?? '90.4150',
        }));
        print("====> [HomeScreen] FlutterOverlayWindow.shareData dispatched mock payload");
      } catch (e, stack) {
        debugPrint("====> FlutterOverlayWindow error: $e\n$stack");
        showCustomSnackBar("Overlay error: $e", isError: true);
      }
    });
  }

  void requestBatteryOptimization() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      return;
    } else if(status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    } else {
      openAppSettings();
    }

    checkPermission();
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController){

      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      bool isRideActive = AppConstants.appMode == AppMode.ride;

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SafeArea(
            top: true,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Container(
                  height: 56,
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Left: 44 px Circular Profile Avatar Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onNavigateToProfile,
                          borderRadius: BorderRadius.circular(500),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              border: Border.all(
                                color: isDark
                                    ? ColorResources.nightStructuralLine
                                    : ColorResources.structuralLine,
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: (profileController.profileModel?.imageFullUrl != null &&
                                      profileController.profileModel!.imageFullUrl!.isNotEmpty)
                                  ? CustomImageWidget(
                                      image: profileController.profileModel!.imageFullUrl!,
                                      height: 44,
                                      width: 44,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      Images.placeholder,
                                      height: 44,
                                      width: 44,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),

                      // 2. Center: Centered Logo with kDebugMode long-press
                      GestureDetector(
                        onLongPress: kDebugMode ? () => _testFloatingOverlay() : null,
                        child: Container(
                          width: 104,
                          height: 44,
                          alignment: Alignment.center,
                          child: Image.asset(
                            Images.logo,
                            height: 28,
                            width: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // 3. Right: 44 px Circular Notification Button with 8 px Alert Red dot
                      GetBuilder<NotificationController>(
                        builder: (notificationController) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                              borderRadius: BorderRadius.circular(500),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).cardColor,
                                  border: Border.all(
                                    color: isDark
                                        ? ColorResources.nightStructuralLine
                                        : ColorResources.structuralLine,
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_none_rounded,
                                      size: 22,
                                      color: isDark
                                          ? ColorResources.nightInk
                                          : ColorResources.inkCharcoal,
                                    ),
                                    if (notificationController.hasNotification)
                                      Positioned(
                                        top: 9,
                                        right: 9,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: ColorResources.alertRed,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(context).cardColor,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        body: RefreshIndicator(
          onRefresh: () async {
            return await _loadData();
          },
          child: Column(children: [

            if(!_isNotificationPermissionGranted)
              permissionWarning(isBatteryPermission: false, onTap: requestNotificationPermission, closeOnTap: () {
                setState(() {
                  _isNotificationPermissionGranted = true;
                });
              }),

            if(!_isBatteryOptimizationGranted)
              permissionWarning(isBatteryPermission: true, onTap: requestBatteryOptimization, closeOnTap: () {
                setState(() {
                  _isBatteryOptimizationGranted = true;
                });
              }),

            Expanded(
              child: Stack(children: [
                SingleChildScrollView(
                  child: GetBuilder<ProfileController>(builder: (profileController) {

                    var config = Get.find<SplashController>().configModel;

                    bool showReferAndEarn = profileController.profileModel != null && profileController.profileModel!.earnings == 1
                        && (isRideActive ? (config?.riderReferralData?.referalStatus ?? false) : (config?.dmReferralData?.referalStatus ?? false));

                    bool addNewVehicle = profileController.profileModel?.vehicle == null || profileController.profileModel?.vehicle?.vehicleRequestStatus == "pending";

                    bool showEarningWidget = profileController.profileModel != null && profileController.profileModel!.earnings == 1;

                    bool showCashInHandCard = profileController.profileModel != null && profileController.profileModel!.cashInHands! > 0;


                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                      child: Column( children: [

                        if(isRideActive)...[
                         addNewVehicle
                             ? VehicleAddWidget(vehicle: profileController.profileModel?.vehicle)
                             : ActiveRideWidget(),
                        ] else...[
                          ActiveOrderWidget(onNavigateToOrders: ()=> Get.offAll(DashboardScreen(pageIndex: 2)))
                        ],

                        if(showEarningWidget) HomeEarningWidget(profileController: profileController,),

                        isRideActive
                            ? RideOrderCountWidget(profileController: profileController)
                            : OrderCountWidget(profileController: profileController),

                        isRideActive ? RideActivityView() : SizedBox(),

                        if(showCashInHandCard) CashInHandCardWidget(profileController: profileController),

                        if(showReferAndEarn) ReferralCardWidget()

                      ]),
                    );
                  }),
                ),

                if(isRideActive) RideMapNavigationWidget(),
              ]),
            ),
          ]),
        ),
      );
    });
  }

  Widget permissionWarning({required bool isBatteryPermission, required Function() onTap, required Function() closeOnTap}) {
    return GetPlatform.isAndroid ? Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.black87),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [

            if(isBatteryPermission)
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Image.asset(Images.allertIcon, height: 20, width: 20),
              ),

            Expanded(
              child: Row(children: [
                Flexible(
                  child: Text(
                    isBatteryPermission ? 'for_better_performance_allow_notification_to_run_in_background'.tr
                        : 'notification_is_disabled_please_allow_notification'.tr,
                    maxLines: 2, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                const Icon(Icons.arrow_circle_right_rounded, color: Colors.white, size: 24,),
              ]),
            ),

            // const SizedBox(width: 20),
          ]),
        ),
      ),
    ) : const SizedBox();
  }
}
