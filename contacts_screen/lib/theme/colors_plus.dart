import 'package:flutter/material.dart';

class ColorsPlus {
  static Color _pColor = Colors.white;
  static Color _sColor = const Color(0xff53a99a);

  /// Primary color used in the app.
  static Color get primaryColor => _pColor;

  /// Secondary color used in the app.
  static Color get secondaryColor => _sColor;

  /// Sets secondary color.
  static set setSecondaryColor(Color color) {
    _sColor = color;
  }
}
