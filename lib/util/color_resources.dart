import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorResources {

  static Color getRightBubbleColor() {
    return  Theme.of(Get.context!).primaryColor;
  }

  static Color getLeftBubbleColor() {
    return Get.isDarkMode ? const Color(0xA2B7B7BB): Theme.of(Get.context!).disabledColor.withValues(alpha: 0.2);
  }

  static const Color green = Color(0xff24A85C);
  static const Color red = Color(0xffFF5A54);
  static const Color blue = Color(0xff1D95FF);
  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff000000);

  // V4.0 Design Tokens (Light Mode - Paper Cockpit)
  static const Color myardsRed = Color(0xFFFF3131);
  static const Color redDeep = Color(0xFFC72525);
  static const Color canvasMist = Color(0xFFFCFCFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color inkCharcoal = Color(0xFF1B211D);
  static const Color mutedOliveGrey = Color(0xFF66736B);
  static const Color softBlush = Color(0xFFFFE9E9);
  static const Color structuralLine = Color(0xFFDCE6DE);
  static const Color structuralLineSubtle = Color(0x59DCE6DE); // 35% opacity
  static const Color alertRed = Color(0xFFE84D4F);

  // V4.0 Design Tokens (Night Dispatch Dark Mode)
  static const Color nightCanvas = Color(0xFF151817);
  static const Color nightSurface = Color(0xFF202522);
  static const Color nightSurfaceRaised = Color(0xFF2A302C);
  static const Color nightInk = Color(0xFFF3F6F3);
  static const Color nightMuted = Color(0xFFAAB5AD);
  static const Color nightStructuralLine = Color(0xFF3A443E);
  static const Color redNightTint = Color(0xFF3B2424);
  static const Color alertRedDark = Color(0xFFFF6B6B);
}