import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/order_shimmer_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/order_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ActiveOrderWidget extends StatelessWidget {
  final Function()? onNavigateToOrders;
  const ActiveOrderWidget({super.key, this.onNavigateToOrders});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<OrderController>(builder: (orderController) {
      bool hasActiveOrder = orderController.currentOrderList == null || orderController.currentOrderList!.isNotEmpty;
      bool hasMoreOrder = orderController.currentOrderList != null && orderController.currentOrderList!.length > 1;

      if (!hasActiveOrder) {
        return const SizedBox();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header: ACTIVE ORDER
            Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'active_order'.tr.toUpperCase(),
                        style: outfitBold(
                          fontSize: Dimensions.fontSizeSmall,
                          letterSpacing: 0.8,
                          color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorResources.alertRed,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          '${orderController.currentOrderList?.length ?? 0}',
                          style: jetBrainsMonoBold(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hasMoreOrder)
                    InkWell(
                      onTap: onNavigateToOrders,
                      child: Text(
                        'see_all'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            orderController.currentOrderList == null
                ? OrderShimmerWidget(isEnabled: orderController.currentOrderList == null)
                : orderController.currentOrderList!.isNotEmpty
                    ? OrderWidget(
                        orderModel: orderController.currentOrderList![0],
                        isRunningOrder: true,
                        orderIndex: 0,
                        cardWidth: context.width * 0.9,
                      )
                    : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
        ),
      );
    });
  }
}
