import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class RideOrderCountWidget extends StatelessWidget {
  final ProfileController profileController;
  const RideOrderCountWidget({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        0,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: RIDES
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Text(
                  'rides'.tr.toUpperCase(),
                  style: outfitBold(
                    fontSize: Dimensions.fontSizeSmall,
                    letterSpacing: 0.8,
                    color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                  ),
                ),
              ],
            ),
          ),

          // 3-Cell Bento Rail
          IntrinsicHeight(
            child: Row(
              children: [
                _RideOrderCountCardWidget(
                  title: 'today'.tr.toUpperCase(),
                  value: profileController.profileModel?.todayRideCount?.toString(),
                  subTitle: 'rides'.tr.toLowerCase(),
                  isDark: isDark,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                _RideOrderCountCardWidget(
                  title: 'this_week'.tr.toUpperCase(),
                  value: profileController.profileModel?.thisWeekRideCount?.toString(),
                  subTitle: 'rides'.tr.toLowerCase(),
                  isDark: isDark,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                _RideOrderCountCardWidget(
                  title: 'total'.tr.toUpperCase(),
                  value: profileController.profileModel?.totalRides?.toString(),
                  subTitle: 'rides'.tr.toLowerCase(),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RideOrderCountCardWidget extends StatelessWidget {
  final String title;
  final String? value;
  final String subTitle;
  final bool isDark;
  const _RideOrderCountCardWidget({
    required this.title,
    this.value,
    required this.subTitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D1B211D),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: outfitSemiBold(
                fontSize: 10,
                letterSpacing: 0.5,
                color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            value != null
                ? Text(
                    value!,
                    style: jetBrainsMonoBold(
                      fontSize: 22,
                      color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Shimmer(
                    duration: const Duration(seconds: 2),
                    color: Theme.of(context).shadowColor,
                    child: Container(
                      height: 22,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
            const SizedBox(height: 4),
            Text(
              subTitle,
              style: robotoRegular.copyWith(
                fontSize: 11,
                color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


