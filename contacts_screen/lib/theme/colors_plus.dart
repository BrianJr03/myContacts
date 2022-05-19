import 'package:flutter/material.dart';

class ColorsPlus {
  /// Primary color used in the app.
  static Color get primaryColor => Colors.white;

  /// Secondary color used in the app.
  static Color _sColor = const Color(0xff53a99a);

  /// Secondary color used in the app.
  static Color get secondaryColor => _sColor;

  /// Sets secondary color.
  static set setSecondaryColor(Color color) {
    _sColor = color;
  }
}
