import 'package:flutter/cupertino.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF114474); // Azul TSIGO
  static const Color accentColor = Color(0xFFFF7500); // Laranja TSIGO

  static CupertinoThemeData cupertinoTheme = CupertinoThemeData(
    primaryColor: primaryColor,
    textTheme: CupertinoTextThemeData(
      primaryColor: primaryColor,
      textStyle: TextStyle(
        fontFamily: 'SF Pro Display', // Fonte Moderna
        fontSize: 16,
      ),
    ),
  );
}
