import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: const Color(0xFFFF3131),
  secondaryHeaderColor: const Color(0xFFFFE9E9),
  disabledColor: const Color(0xFF66736B),
  brightness: Brightness.light,
  hintColor: const Color(0xFF66736B),
  cardColor: const Color(0xFFFFFFFF),
  shadowColor: const Color(0x121B211D),
  scaffoldBackgroundColor: const Color(0xFFFCFCFC),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF3131))),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFFF3131),
    secondary: Color(0xFFFF3131),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1B211D),
    onPrimary: Colors.white,
  ).copyWith(error: const Color(0xFFE84D4F)),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    backgroundColor: const Color(0xFFFF3131),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(color: Colors.white, height: 60, padding: EdgeInsets.symmetric(vertical: 5)),
  dividerTheme: const DividerThemeData(thickness: 1.0, color: Color(0xFFDCE6DE)),
);