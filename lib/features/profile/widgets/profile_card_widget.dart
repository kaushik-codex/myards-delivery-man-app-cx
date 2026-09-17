import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_level_details_widget.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ProfileCardWidget extends StatelessWidget {
  final ProfileController profileController;
  final bool isRideActive;

  const ProfileCardWidget({
    super.key,
    required this.profileController,
    required this.isRideActive,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final config = Get.find<SplashController>().configModel;
    final profile = profileController.profileModel;

    if (profile == null) return const SizedBox();

    String tierLabel;
    if (isRideActive && config?.riderLevelStatus == 1 && profileController.levelModel?.data?.currentLevel?.name != null) {
      tierLabel = profileController.levelModel!.data!.currentLevel!.name!;
    } else {
      tierLabel = isRideActive ? 'Verified Rider' : 'Verified Partner';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Top-right subtle ambient red accent
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? ColorResources.redNightTint : ColorResources.softBlush).withValues(alpha: 0.35),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Partner Info Row: Avatar + Name + Verified Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 64 px Photo Avatar with 1.5 px Structural Line ring + bottom-right check badge
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? ColorResources.nightSurfaceRaised : const Color(0xFFF7FAF7),
                            border: Border.all(
                              color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: CustomImageWidget(
                              image: profile.imageFullUrl ?? '',
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                color: Theme.of(context).cardColor,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.check, size: 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    // Partner Name, Verified status and Tier
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${profile.fName} ${profile.lName}',
                                  style: outfitBold(
                                    fontSize: 18,
                                    letterSpacing: -0.2,
                                    color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.verified,
                                size: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Tier / Level Pill Badge
                          InkWell(
                            onTap: (isRideActive && config?.riderLevelStatus == 1)
                                ? () {
                                    profileController.getProfileLevelInfo();
                                    Get.bottomSheet(const ProfileLevelDetailsWidget());
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? ColorResources.nightSurfaceRaised : const Color(0xFFF7FAF7),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tierLabel,
                                    style: jetBrainsMonoMedium(
                                      fontSize: 11,
                                      color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 1 px Horizontal Sub-Divider
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                  ),
                ),

                // Metric Indicators Sub-grid (2 side-by-side technical Bento cards)
                Row(
                  children: [
                    // Sub-card 1: Driver Score (Ride) / Total Orders (Delivery)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? ColorResources.nightSurfaceRaised : const Color(0xFFF7FAF7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRideActive ? 'DRIVER SCORE' : 'TOTAL ORDERS',
                              style: outfitBold(
                                fontSize: 10,
                                letterSpacing: 0.5,
                                color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (isRideActive)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${profile.avgRating ?? 0}',
                                    style: jetBrainsMonoBold(
                                      fontSize: 18,
                                      color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                  const SizedBox(width: 3),
                                  Text(
                                    '(${profile.ratingCount ?? 0})',
                                    style: jetBrainsMonoRegular(
                                      fontSize: 11,
                                      color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${profile.orderCount ?? 0}',
                                    style: jetBrainsMonoBold(
                                      fontSize: 18,
                                      color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'completed'.tr.toLowerCase(),
                                    style: robotoRegular.copyWith(
                                      fontSize: 11,
                                      color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Sub-card 2: Fleet Service (Days Active)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? ColorResources.nightSurfaceRaised : const Color(0xFFF7FAF7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FLEET SERVICE',
                              style: outfitBold(
                                fontSize: 10,
                                letterSpacing: 0.5,
                                color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${profile.memberSinceDays ?? 0}',
                                  style: jetBrainsMonoBold(
                                    fontSize: 18,
                                    color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'days'.tr.toLowerCase(),
                                  style: robotoRegular.copyWith(
                                    fontSize: 11,
                                    color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
