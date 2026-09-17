import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/ride_helper.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
class ActiveRideWidget extends StatelessWidget {
  const ActiveRideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<RideController>(
        builder: (rideController) {
          String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
          String tripDate = '0', suffix = 'st';
          List<dynamic> extraRoute =[];
          int count = 1;
          if(rideController.lastRideDetails != null && rideController.lastRideDetails!.isNotEmpty){
            tripDate = DateConverterHelper.dateTimeStringToDateOnly(rideController.lastRideDetails![0].createdAt!);
            if(tripDate == "1"){
              suffix = "st";
            }else if(tripDate == "2"){
              suffix = "nd";
            }else if(tripDate == "3"){
              suffix = "rd";
            }else{
              suffix = "th";
            }

            for(int i =0; i< extraRoute.length; i++){
              if(extraRoute[i] != ''){
                count ++;
                if (kDebugMode) {
                  print(count);
                }
              }
            }
          }
          return rideController.lastRideDetails != null && rideController.lastRideDetails!.isNotEmpty && rideController.lastRideDetails![0].currentStatus != 'completed' && rideController.lastRideDetails![0].currentStatus != 'cancelled' ? InkWell(
            onTap: ()=> RideHelper.navigateToNextScreen(id: rideController.lastRideDetails![0].id),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x121B211D), blurRadius: 28, offset: Offset(0, 10)),
                ],
              ),
              margin: const EdgeInsets.only(bottom: 10, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    'active_ride'.tr.toUpperCase(),
                    style: outfitBold(
                      fontSize: Dimensions.fontSizeSmall,
                      letterSpacing: 0.8,
                      color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                    ),
                  ),

                  TextButton(
                    onPressed: ()=> RideHelper.navigateToNextScreen(id: rideController.lastRideDetails![0].id),

                    child: Text('see_details'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                  ),
                ]),

                Row(children: [
                  Text('${'ride_id'.tr} # ${rideController.lastRideDetails?[0].refId}', style: jetBrainsMonoBold(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                  Container(
                    height: 15, width: 2, color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                  ),
                  Text('$tripDate$suffix ', style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                  Text(DateConverterHelper.dateTimeStringToMonthAndYear(rideController.lastRideDetails![0].createdAt!), style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Column(children: [
                    Text('est_trip_amount'.tr, style: robotoBold.copyWith(color: Theme.of(context).disabledColor),),
                    Text(PriceConverterHelper.convertPrice(double.tryParse(rideController.lastRideDetails![0].estimatedFare??'0')??0), style: jetBrainsMonoBold(fontSize: Dimensions.fontSizeExtraLarge, color: isDark ? ColorResources.nightInk : ColorResources.inkCharcoal),),
                    Text(capitalize(rideController.lastRideDetails![0].currentStatus!.tr), style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text('${'est_drop_off_time'.tr} - ${rideController.lastRideDetails![0].estimatedTime} min', style: jetBrainsMonoBold(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ]),
            ),
          ) : const SizedBox();
        }
    );
  }
}