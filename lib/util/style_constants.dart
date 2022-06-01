import 'package:flutter/material.dart';

/// A set of style constants that are used within the application. May be extended
/// in the future to make it look more consistent.
class StyleConstants {
  static const double cardBorderRadiusSize = 25;
  static const BoxShadow cardBoxShadow = BoxShadow(
    offset: Offset(0, 5),
    blurRadius: 10,
    color: Color.fromARGB(100, 0, 0, 0),
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(8);
  static const EdgeInsets cardMargin = EdgeInsets.all(12);
}
