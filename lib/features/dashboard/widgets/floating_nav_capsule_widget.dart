import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/images.dart';

class FloatingNavCapsuleWidget extends StatelessWidget {
  final int pageIndex;
  final Function(int) onTap;
  final bool isRideActive;

  const FloatingNavCapsuleWidget({
    super.key,
    required this.pageIndex,
    required this.onTap,
    required this.isRideActive,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(500),
        border: Border.all(
          color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x4D000000) : const Color(0x1F1B211D),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          final double tabWidth = totalWidth / 3;
          final int activeIndex = pageIndex.clamp(0, 2);

          return Stack(
            children: [
              // 1. Sliding Street-Light Indicator Capsule
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: activeIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? ColorResources.redNightTint : ColorResources.softBlush,
                    borderRadius: BorderRadius.circular(500),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      height: 2,
                      width: tabWidth * 0.45,
                      decoration: BoxDecoration(
                        color: ColorResources.myardsRed,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Interactive Navigation Tabs
              Row(
                children: [
                  _buildTab(
                    context: context,
                    index: 0,
                    icon: Images.home,
                    label: 'home'.tr.toUpperCase(),
                    isSelected: pageIndex == 0,
                    isDark: isDark,
                  ),
                  _buildTab(
                    context: context,
                    index: 1,
                    icon: Images.request,
                    label: 'request'.tr.toUpperCase(),
                    isSelected: pageIndex == 1,
                    isDark: isDark,
                    hasBadge: true,
                  ),
                  _buildTab(
                    context: context,
                    index: 2,
                    icon: Images.bag,
                    label: isRideActive ? 'history'.tr.toUpperCase() : 'orders'.tr.toUpperCase(),
                    isSelected: pageIndex == 2,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required int index,
    required String icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    bool hasBadge = false,
  }) {
    final Color activeColor = ColorResources.myardsRed;
    final Color inactiveColor = isDark
        ? ColorResources.nightMuted
        : ColorResources.mutedOliveGrey.withValues(alpha: 0.75);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(500),
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            offset: isSelected ? const Offset(0, -0.04) : Offset.zero,
            child: SizedBox(
              height: 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        icon,
                        height: 19,
                        width: 19,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                      if (hasBadge)
                        Positioned(
                          top: -5,
                          right: -12,
                          child: GetBuilder<RideController>(
                            builder: (rideController) {
                              return GetBuilder<OrderController>(
                                builder: (orderController) {
                                  final int orderCount = isRideActive
                                      ? (rideController.pendingRideRequestModel?.totalSize ?? 0)
                                      : (orderController.latestOrderList?.length ?? 0);

                                  if (orderCount <= 0) return const SizedBox();

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                                    decoration: BoxDecoration(
                                      color: ColorResources.alertRed,
                                      borderRadius: BorderRadius.circular(500),
                                      border: Border.all(
                                        color: Theme.of(context).cardColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$orderCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? activeColor : inactiveColor,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
