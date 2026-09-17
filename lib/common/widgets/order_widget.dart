import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool isRunningOrder;
  final int orderIndex;
  final double cardWidth;
  const OrderWidget({super.key, required this.orderModel, required this.isRunningOrder, required this.orderIndex, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool parcel = orderModel.orderType == 'parcel';
    bool prescriptio = (orderModel.prescriptionOrder ?? false);

    return InkWell(
      onTap: () {
        Get.toNamed(
          RouteHelper.getOrderDetailsRoute(orderModel.id),
          arguments: OrderDetailsScreen(orderId: orderModel.id, isRunningOrder: isRunningOrder, orderIndex: orderIndex),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
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
        child: Column(children: [

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Row(children: [

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(parcel ? 'parcel'.tr : 'order'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),

                Row(children: [
                  Text('# ${orderModel.id} ', style: jetBrainsMonoBold(fontSize: Dimensions.fontSizeDefault, color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal)),

                  parcel || prescriptio ? const SizedBox() : Text('(${orderModel.detailsCount} ${'item'.tr})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                ]),
              ]),

              const Expanded(child: SizedBox()),

              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
                  decoration: BoxDecoration(
                    color: orderModel.paymentStatus == 'paid' ? ColorResources.green.withValues(alpha: 0.1) : ColorResources.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Text(
                    orderModel.paymentStatus == 'paid' ? 'paid'.tr : 'unpaid'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: orderModel.paymentStatus == 'paid' ? ColorResources.green : ColorResources.red),
                  ),
                ),
                const SizedBox(height: 2),

                Text(
                  orderModel.paymentMethod == 'cash_on_delivery' ? 'cod'.tr : orderModel.paymentMethod == 'partial_payment' ? 'partially_pay'.tr : 'digitally_paid'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                ),

              ]),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 0),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                parcel
                    ? Image.asset((parcel || orderModel.orderStatus == 'picked_up') ? Images.personIcon : Images.house, width: 20, height: 20)
                    : Icon(Icons.store, size: 18, color: Theme.of(context).hintColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Expanded(
                  child: Text(
                    parcel ? 'customer_location'.tr : (parcel && orderModel.orderStatus == 'picked_up') ? 'receiver_location'.tr : orderModel.storeName?? 'store_not_found'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(),

              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                Icon(Icons.location_on, size: 20, color: Theme.of(context).hintColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Expanded(child: Text(
                  (parcel && orderModel.orderStatus != 'picked_up') ? orderModel.deliveryAddress!.address.toString() : (parcel && orderModel.orderStatus == 'picked_up') ? orderModel.receiverDetails!.address.toString() : orderModel.storeAddress ?? 'address_not_found'.tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

            ]),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: isDark ? ColorResources.nightSurfaceRaised : const Color(0xFFF7FAF7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(19), bottomRight: Radius.circular(19),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                  width: 1,
                ),
              ),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed: () {
                  Get.toNamed(
                    RouteHelper.getOrderDetailsRoute(orderModel.id),
                    arguments: OrderDetailsScreen(orderId: orderModel.id, isRunningOrder: isRunningOrder, orderIndex: orderIndex),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  minimumSize: const Size(100, 38),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine, width: 1),
                  ),
                ),
                child: Text(
                  'details'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall),
                ),
              ),
              const SizedBox(width: 12.0),

              TextButton(
                onPressed: () async {
                  String url;
                  if(parcel && (orderModel.orderStatus == 'picked_up')) {
                    url = 'https://www.google.com/maps/dir/?api=1&destination=${orderModel.receiverDetails!.latitude}'
                        ',${orderModel.receiverDetails!.longitude}&mode=d';
                  }else if(parcel) {
                    url = 'https://www.google.com/maps/dir/?api=1&destination=${orderModel.deliveryAddress!.latitude}'
                        ',${orderModel.deliveryAddress!.longitude}&mode=d';
                  }else if(orderModel.orderStatus == 'picked_up') {
                    url = 'https://www.google.com/maps/dir/?api=1&destination=${orderModel.deliveryAddress!.latitude}'
                        ',${orderModel.deliveryAddress!.longitude}&mode=d';
                  }else {
                    url = 'https://www.google.com/maps/dir/?api=1&destination=${orderModel.storeLat ?? '0'}'
                        ',${orderModel.storeLng ?? '0'}&mode=d';
                  }
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url, mode: LaunchMode.externalApplication);
                  } else {
                    showCustomSnackBar('${'could_not_launch'.tr} $url');
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(100, 38),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(children: [
                  Icon(Icons.directions, size: 16, color: Theme.of(context).cardColor),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text(
                    'direction'.tr,
                    style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                  ),
                ]),
              ),
            ]),
          ),

        ]),
      ),
    );
  }
}