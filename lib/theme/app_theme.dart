// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

ThemeData buildAppTheme({required bool isDark}) {
  final brightness = isDark ? Brightness.dark : Brightness.light;
  final backgroundColor = isDark ? Colors.black : Colors.white;
  final foregroundColor = isDark ? Colors.white : Colors.black;

  return ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey,
      accentColor: Colors.pinkAccent,
      brightness: brightness,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: foregroundColor),
      titleTextStyle: TextStyle(
        color: foregroundColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerTheme: const DividerThemeData(
      thickness: 0,
      color: Colors.transparent,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: backgroundColor,
      collapsedBackgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.transparent),
      ),
      collapsedShape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.transparent),
      ),
    ),
    useMaterial3: true,
  );
}
