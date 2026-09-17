import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class HomeEarningWidget extends StatelessWidget {
  final ProfileController profileController;
  const HomeEarningWidget({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: EARNINGS
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Text(
                  'earnings'.tr.toUpperCase(),
                  style: outfitBold(
                    fontSize: Dimensions.fontSizeSmall,
                    letterSpacing: 0.8,
                    color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                  ),
                ),
              ],
            ),
          ),

          // Operational 20 px Asymmetric Panel
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x121B211D),
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Hero: BALANCE
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark ? ColorResources.redNightTint : ColorResources.softBlush,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        Images.wallet,
                        width: 24,
                        height: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'balance'.tr.toUpperCase(),
                            style: outfitSemiBold(
                              fontSize: 11,
                              letterSpacing: 0.5,
                              color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          profileController.profileModel != null
                              ? Text(
                                  PriceConverterHelper.convertPrice(profileController.profileModel!.balance),
                                  style: jetBrainsMonoBold(
                                    fontSize: 26,
                                    letterSpacing: -0.5,
                                    color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Shimmer(
                                  duration: const Duration(seconds: 2),
                                  color: Theme.of(context).shadowColor,
                                  child: Container(
                                    height: 26,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Subtle 1 px horizontal divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                  ),
                ),

                // Bottom Divided Metric Rail: TODAY | THIS WEEK | THIS MONTH
                Row(
                  children: [
                    _EarningWidget(
                      title: 'today'.tr.toUpperCase(),
                      amount: profileController.profileModel?.todaysEarning,
                      isDark: isDark,
                    ),
                    Container(
                      height: 32,
                      width: 1,
                      color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                    ),
                    _EarningWidget(
                      title: 'this_week'.tr.toUpperCase(),
                      amount: profileController.profileModel?.thisWeekEarning,
                      isDark: isDark,
                    ),
                    Container(
                      height: 32,
                      width: 1,
                      color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                    ),
                    _EarningWidget(
                      title: 'this_month'.tr.toUpperCase(),
                      amount: profileController.profileModel?.thisMonthEarning,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }
}

class _EarningWidget extends StatelessWidget {
  final String title;
  final double? amount;
  final bool isDark;
  const _EarningWidget({required this.title, required this.amount, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: outfitSemiBold(
              fontSize: 10,
              letterSpacing: 0.4,
              color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          amount != null
              ? Text(
                  PriceConverterHelper.convertPrice(amount),
                  style: jetBrainsMonoBold(
                    fontSize: 15,
                    color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                )
              : Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: amount == null,
                  color: Theme.of(context).shadowColor,
                  child: Container(
                    height: 18,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
