import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: const Color(0xFFFF3131),
  secondaryHeaderColor: const Color(0xFF3B2424),
  disabledColor: const Color(0xFFAAB5AD),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFAAB5AD),
  cardColor: const Color(0xFF202522),
  shadowColor: const Color(0x4D000000),
  scaffoldBackgroundColor: const Color(0xFF151817),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF3131))),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFF3131),
    secondary: Color(0xFFC72525),
    surface: Color(0xFF202522),
    onSurface: Color(0xFFF3F6F3),
    onPrimary: Colors.white,
  ).copyWith(error: const Color(0xFFFF6B6B)),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF202522), surfaceTintColor: Color(0xFF202522)),
  dialogTheme: const DialogThemeData(surfaceTintColor: Color(0xFF202522)),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    backgroundColor: const Color(0xFFC72525),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(color: Color(0xFF202522), height: 60, padding: EdgeInsets.symmetric(vertical: 5)),
  dividerTheme: const DividerThemeData(thickness: 1.0, color: Color(0xFF3A443E)),
);