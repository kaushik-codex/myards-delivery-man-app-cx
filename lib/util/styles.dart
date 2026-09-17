import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

const robotoRegular = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
);

const robotoMedium = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeDefault,
);

const robotoSemiBold = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w600,
  fontSize: Dimensions.fontSizeDefault,
);

const robotoBold = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w700,
  fontSize: Dimensions.fontSizeDefault,
);

const robotoBlack = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w900,
  fontSize: Dimensions.fontSizeDefault,
);

// V4.0 Typography Engine: JetBrains Mono for tabular operational metrics
TextStyle jetBrainsMonoRegular({double? fontSize, Color? color, FontWeight? fontWeight, double? letterSpacing}) =>
    GoogleFonts.jetBrainsMono(
      fontSize: fontSize ?? Dimensions.fontSizeDefault,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
    );

TextStyle jetBrainsMonoMedium({double? fontSize, Color? color, FontWeight? fontWeight, double? letterSpacing}) =>
    GoogleFonts.jetBrainsMono(
      fontSize: fontSize ?? Dimensions.fontSizeDefault,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
    );

TextStyle jetBrainsMonoBold({double? fontSize, Color? color, FontWeight? fontWeight, double? letterSpacing}) =>
    GoogleFonts.jetBrainsMono(
      fontSize: fontSize ?? Dimensions.fontSizeDefault,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing,
    );

// V4.0 Typography Engine: Outfit for modern UI headers and labels
TextStyle outfitRegular({double? fontSize, Color? color, FontWeight? fontWeight, double? letterSpacing}) =>
    GoogleFonts.outfit(
      fontSize: fontSize ?? Dimensions.fontSizeDefault,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
    );

TextStyle outfitMedium({double? fontSize, Color? color, FontWeight? fontWeight, double? letterSpacing}) =>
    GoogleFonts.outfit(
      fontSize: fontSize ?? Dimensions.fontSizeDefault,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
    );

TextStyle outfitSemiBold({double? fontSize, Color? color, FontWeight? fontWeight, double? letterSpacing}) =>
    GoogleFonts.outfit(
      fontSize: fontSize ?? Dimensions.fontSizeDefault,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
    );

TextStyle outfitBold({double? fontSize, Color? color, FontWeight? fontWeight, double? letterSpacing}) =>
    GoogleFonts.outfit(
      fontSize: fontSize ?? Dimensions.fontSizeDefault,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing,
    );

Color getStatusButtonColor(String? status){
  return status == "completed" ? Theme.of(Get.context!).primaryColor
      : status == "cancelled" ? Theme.of(Get.context!).colorScheme.error
      : status == "ongoing" ? Colors.orange
      :  status == "accepted" ? Colors.blue : Theme.of(Get.context!).hintColor;
}