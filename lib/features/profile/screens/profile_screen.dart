import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_delivery/common/controllers/theme_controller.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_confirmation_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/home/widgets/location_access_dialog.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/notification_status_change_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_card_widget.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_group_widget.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/add_vehicle/screens/vehicle_details_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/help_and_support/screens/help_and_support_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/leaderboard/screens/leaderboard_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/review/screens/review_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/safety/screen/safety_policy_screen.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/pusher_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AppLifecycleListener _listener;
  bool isRideActive = AppConstants.appMode == AppMode.ride;

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );
    Get.find<ProfileController>().getProfile();
    if (isRideActive) {
      Get.find<ProfileController>().getProfileLevelInfo();
    }
  }

  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        checkBatteryPermission();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  void checkBatteryPermission() async {
    Future.delayed(const Duration(milliseconds: 400), () async {
      if (await Permission.ignoreBatteryOptimizations.status.isDenied) {
        Get.find<ProfileController>().setBackgroundNotificationActive(false);
      } else {
        Get.find<ProfileController>().setBackgroundNotificationActive(true);
      }
    });
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: GetBuilder<ProfileController>(builder: (profileController) {
          var config = Get.find<SplashController>().configModel;

          bool showReferAndEarn = profileController.profileModel != null &&
              profileController.profileModel!.earnings == 1 &&
              (isRideActive
                  ? (config?.riderReferralData?.referalStatus ?? false)
                  : (config?.dmReferralData?.referalStatus ?? false));

          if (profileController.profileModel == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // V4.0 Transparent Header (56 px) with 44 px circular back affordance
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Get.back();
                        }
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A1B211D),
                              blurRadius: 12,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal,
                        ),
                      ),
                    ),
                    Text(
                      'profile'.tr,
                      style: outfitBold(
                        fontSize: 18,
                        letterSpacing: -0.2,
                        color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal,
                      ),
                    ),
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
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A1B211D),
                                    blurRadius: 12,
                                    offset: Offset(0, 2),
                                  ),
                                ],
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
                                          color: Theme.of(context).primaryColor,
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

              // Scrollable Categorized Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          // Profile Card (from Stitch Profile Card Design)
                          ProfileCardWidget(
                            profileController: profileController,
                            isRideActive: isRideActive,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          // GROUP 1: OVERVIEW
                          ProfileGroupWidget(
                            title: 'overview'.tr,
                            children: [
                              // Online Status Switch Row
                              ProfileGroupItemWidget(
                                iconImage: Images.online,
                                title: 'online_status'.tr,
                                subtitle: 'manage_your_delivery_availability'.tr,
                                trailing: GetBuilder<ProfileController>(builder: (profileController) {
                                  return GetBuilder<RideController>(builder: (rideController) {
                                    return GetBuilder<OrderController>(builder: (orderController) {
                                      bool isRide = AppConstants.appMode == AppMode.ride;
                                      bool haveRunningRide = rideController.lastRideDetails != null &&
                                          rideController.lastRideDetails!.isNotEmpty &&
                                          rideController.lastRideDetails![0].currentStatus != 'completed' &&
                                          rideController.lastRideDetails![0].currentStatus != 'cancelled';

                                      return (profileController.profileModel != null)
                                          ? Transform.scale(
                                              scale: 0.7,
                                              child: CupertinoSwitch(
                                                value: profileController.profileModel!.active == 1,
                                                activeTrackColor: Theme.of(context).primaryColor,
                                                inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                                onChanged: profileController.isActiveStatusLoading
                                                    ? null
                                                    : (bool isActive) async {
                                                        if (!isRide &&
                                                            !isActive &&
                                                            (orderController.currentOrderList?.isNotEmpty ?? false)) {
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
                                                        } else if (isRide && !isActive && haveRunningRide) {
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
                                                          if (!isActive) {
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
                                                                        backgroundColor: Theme.of(context)
                                                                            .disabledColor
                                                                            .withValues(alpha: 0.1),
                                                                        fontColor: Theme.of(context).disabledColor,
                                                                        isBorder: true,
                                                                      ),
                                                                    ),
                                                                  ]),
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            LocationPermission permission =
                                                                await Geolocator.checkPermission();
                                                            if (permission == LocationPermission.denied ||
                                                                permission == LocationPermission.deniedForever ||
                                                                (GetPlatform.isIOS
                                                                    ? false
                                                                    : permission == LocationPermission.whileInUse)) {
                                                              _checkPermission(
                                                                  () => profileController.updateActiveStatus());
                                                            } else {
                                                              profileController.updateActiveStatus();
                                                            }
                                                          }
                                                        }
                                                      },
                                              ),
                                            )
                                          : const SizedBox();
                                    });
                                  });
                                }),
                              ),

                              // Conditional Financial & Earning Links
                              if (profileController.profileModel != null &&
                                  profileController.profileModel!.earnings == 1 &&
                                  AppConstants.appMode == AppMode.delivery &&
                                  !isRideActive)
                                ProfileGroupItemWidget(
                                  iconImage: Images.earning,
                                  title: 'my_earning'.tr,
                                  onTap: () => Get.toNamed(RouteHelper.getMyEarningRoute()),
                                ),

                              if (profileController.profileModel != null &&
                                  profileController.profileModel!.earnings == 1)
                                ProfileGroupItemWidget(
                                  iconImage: Images.earningReport,
                                  title: 'earning_report'.tr,
                                  onTap: () => Get.toNamed(RouteHelper.getEarningReportRoute()),
                                ),

                              if (profileController.profileModel != null &&
                                  profileController.profileModel!.earnings == 1)
                                ProfileGroupItemWidget(
                                  iconImage: Images.emptyWallet,
                                  title: 'my_account'.tr,
                                  onTap: () => Get.toNamed(RouteHelper.getMyAccountRoute()),
                                ),

                              ProfileGroupItemWidget(
                                icon: Icons.money,
                                title: 'withdraw_method'.tr,
                                onTap: () => Get.toNamed(RouteHelper.getWithdrawMethodRoute()),
                              ),

                              if (config?.disbursementType == 'automated' &&
                                  profileController.profileModel!.type != 'store_wise' &&
                                  profileController.profileModel!.earnings != 0)
                                ProfileGroupItemWidget(
                                  icon: Icons.payments,
                                  title: 'disbursement'.tr,
                                  onTap: () => Get.toNamed(RouteHelper.getDisbursementRoute()),
                                ),

                              if (showReferAndEarn)
                                ProfileGroupItemWidget(
                                  iconImage: Images.earning,
                                  title: 'refer_and_earn'.tr,
                                  onTap: () => Get.to(() => const ReferAndEarnScreen()),
                                ),
                            ],
                          ),

                          // GROUP 2: ACCOUNT
                          ProfileGroupWidget(
                            title: 'account'.tr,
                            children: [
                              ProfileGroupItemWidget(
                                iconImage: Images.editUser,
                                title: 'edit_profile'.tr,
                                onTap: () => Get.toNamed(RouteHelper.getUpdateProfileRoute()),
                              ),

                              if (profileController.profileModel?.vehicle != null && isRideActive)
                                ProfileGroupItemWidget(
                                  iconImage: Images.car,
                                  title: 'vehicle_details'.tr,
                                  onTap: () => Get.to(() => VehicleDetailsScreen()),
                                ),

                              ProfileGroupItemWidget(
                                iconImage: Images.security,
                                title: 'change_password'.tr,
                                onTap: () =>
                                    Get.toNamed(RouteHelper.getResetPasswordRoute('', '', 'password-change')),
                              ),

                              GetBuilder<LocalizationController>(builder: (localizationController) {
                                String languageName = '';
                                if (localizationController.languages.isNotEmpty &&
                                    localizationController.selectedLanguageIndex < localizationController.languages.length) {
                                  languageName = localizationController.languages[localizationController.selectedLanguageIndex].languageName ?? '';
                                }
                                return ProfileGroupItemWidget(
                                  iconImage: Images.translation,
                                  title: 'language'.tr,
                                  valueText: languageName,
                                  onTap: () => _manageLanguageFunctionality(),
                                );
                              }),

                              ProfileGroupItemWidget(
                                icon: Icons.dark_mode_outlined,
                                title: 'dark_mode'.tr,
                                valueText: Get.isDarkMode ? 'dark'.tr : 'light'.tr,
                                trailing: Transform.scale(
                                  scale: 0.7,
                                  child: CupertinoSwitch(
                                    value: Get.isDarkMode,
                                    activeTrackColor: Theme.of(context).primaryColor,
                                    inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                    onChanged: (val) => Get.find<ThemeController>().toggleTheme(),
                                  ),
                                ),
                                onTap: () => Get.find<ThemeController>().toggleTheme(),
                              ),

                              GetBuilder<AuthController>(builder: (authController) {
                                return ProfileGroupItemWidget(
                                  iconImage: Images.settingIcon,
                                  title: 'system_notification'.tr,
                                  trailing: Transform.scale(
                                    scale: 0.7,
                                    child: CupertinoSwitch(
                                      value: authController.notification,
                                      activeTrackColor: Theme.of(context).primaryColor,
                                      inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                      onChanged: (val) => showCustomBottomSheet(
                                          child: const NotificationStatusChangeBottomSheet()),
                                    ),
                                  ),
                                  onTap: () => showCustomBottomSheet(
                                      child: const NotificationStatusChangeBottomSheet()),
                                );
                              }),

                              if (GetPlatform.isAndroid)
                                ProfileGroupItemWidget(
                                  iconImage: Images.notificationBall,
                                  title: 'background_notification'.tr,
                                  trailing: Transform.scale(
                                    scale: 0.7,
                                    child: CupertinoSwitch(
                                      value: profileController.backgroundNotification,
                                      activeTrackColor: Theme.of(context).primaryColor,
                                      inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                      onChanged: (val) =>
                                          showBgNotificationBottomSheet(profileController.backgroundNotification),
                                    ),
                                  ),
                                  onTap: () =>
                                      showBgNotificationBottomSheet(profileController.backgroundNotification),
                                ),
                            ],
                          ),

                          // GROUP 3: SUPPORT
                          ProfileGroupWidget(
                            title: 'support'.tr,
                            children: [
                              ProfileGroupItemWidget(
                                iconImage: Images.message,
                                title: 'conversation'.tr,
                                onTap: () => Get.toNamed(RouteHelper.getConversationListRoute()),
                              ),

                              ProfileGroupItemWidget(
                                iconImage: Images.support,
                                title: 'help_and_support'.tr,
                                onTap: () => Get.to(() => const HelpAndSupportScreen()),
                              ),

                              if (isRideActive)
                                ProfileGroupItemWidget(
                                  iconImage: Images.noReview,
                                  title: 'my_reviews'.tr,
                                  onTap: () => Get.to(() => const ReviewScreen()),
                                ),

                              if (isRideActive)
                                ProfileGroupItemWidget(
                                  iconImage: Images.leaderBoardIcon,
                                  title: 'leader_board'.tr,
                                  onTap: () => Get.to(() => const LeaderboardScreen()),
                                ),

                              if (isRideActive)
                                ProfileGroupItemWidget(
                                  iconImage: Images.shieldTick,
                                  title: 'safety'.tr,
                                  onTap: () => Get.to(() => const SafetyPolicyScreen()),
                                ),
                            ],
                          ),

                          // GROUP 4: LEGAL & SESSION
                          ProfileGroupWidget(
                            title: 'legal_and_session'.tr.isNotEmpty && 'legal_and_session'.tr != 'legal_and_session'
                                ? 'legal_and_session'.tr
                                : 'Legal & Session',
                            children: [
                              ProfileGroupItemWidget(
                                iconImage: Images.document,
                                title: 'terms_condition'.tr,
                                onTap: () => Get.toNamed(RouteHelper.getTermsRoute()),
                              ),

                              ProfileGroupItemWidget(
                                iconImage: Images.document,
                                title: 'privacy_policy'.tr,
                                onTap: () => Get.toNamed(RouteHelper.getPrivacyRoute()),
                              ),

                              ProfileGroupItemWidget(
                                icon: Icons.logout,
                                title: 'logout'.tr,
                                onTap: () {
                                  Get.dialog(ConfirmationDialogWidget(
                                    icon: Images.support,
                                    description: 'are_you_sure_to_logout'.tr,
                                    isLogOut: true,
                                    onYesPressed: () {
                                      PusherHelper().pusherDisconnectPusher();
                                      Get.find<AuthController>().clearSharedData();
                                      Get.find<ProfileController>().stopLocationRecord();
                                      Get.offAllNamed(RouteHelper.getSignInRoute());
                                    },
                                  ));
                                },
                              ),
                            ],
                          ),

                          // ISOLATED ALERT RED DESTRUCTIVE ROW: Delete Account
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x22E84D4F) : ColorResources.softBlush,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: ColorResources.alertRed.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A1B211D),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ProfileGroupItemWidget(
                                iconImage: Images.trash,
                                title: 'delete_account'.tr,
                                isDestructive: true,
                                onTap: () {
                                  Get.dialog(
                                    ConfirmationDialogWidget(
                                      icon: Images.warning,
                                      title: 'are_you_sure_to_delete_account'.tr,
                                      description: 'it_will_remove_your_all_information'.tr,
                                      isLogOut: true,
                                      onYesPressed: () => profileController.deleteDriver(),
                                    ),
                                    useSafeArea: false,
                                  );
                                },
                              ),
                            ),
                          ),

                          // Footer Version Metadata
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraLarge),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${'version'.tr}: ',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                                  ),
                                ),
                                Text(
                                  AppConstants.appVersion.toString(),
                                  style: jetBrainsMonoMedium(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom clearance for comfortable scrolling
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void showBgNotificationBottomSheet(bool allow) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              '${!allow ? 'allow'.tr : 'disable'.tr} ${AppConstants.appName} ${!allow ? 'to_run_notification_in_background'.tr : 'from_running_notification_in_background'.tr}',
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            Text(
              allow
                  ? '(${AppConstants.appName} -> Battery -> Select Optimized or any Recommended)'
                  : 'Or (${AppConstants.appName} ->  Battery -> No restriction)',
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            _buildInfoText("you_will_be_able_to_get_order_notification_even_if_you_are_not_in_the_app".tr),
            _buildInfoText(
                "${AppConstants.appName} ${!allow ? 'will_run_notification_service_in_the_background_always'.tr : 'will_not_run_notification_service_in_the_background_always'.tr}"),
            _buildInfoText(!allow
                ? "notification_will_always_send_alert_from_the_background".tr
                : 'notification_will_not_always_send_alert_from_the_background'.tr),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("cancel".tr, style: robotoMedium),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                ElevatedButton(
                  onPressed: () async {
                    if (await Permission.ignoreBatteryOptimizations.status.isGranted) {
                      openAppSettings();
                    } else {
                      await Permission.ignoreBatteryOptimizations.request();
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "okay".tr,
                    style: robotoMedium.copyWith(color: Theme.of(context).cardColor),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
      isScrollControlled: true,
    ).then((value) {
      checkBatteryPermission();
    });
  }

  Widget _buildInfoText(String text) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: robotoRegular,
      ),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) =>
        Get.find<LocalizationController>().setLanguage(Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
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
      Get.dialog(LocationAccessDialog(
        onConfirm: () async {
          Get.back();
          await Geolocator.openAppSettings();
          Future.delayed(const Duration(seconds: 3), () {
            if (GetPlatform.isAndroid) _checkPermission(callback);
          });
        },
      ));
    } else {
      callback();
    }
  }
}
