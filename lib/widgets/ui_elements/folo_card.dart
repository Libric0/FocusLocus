import 'package:flutter/material.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/util/style_constants.dart';

/// A card-widget that can be used as a simple, yet elegant backdrop for elements
/// on quiz-cards
class FoloCard extends StatelessWidget {
  final bool hasMargin;
  final Color color;
  final Widget child;
  final double width;
  const FoloCard({
    required this.child,
    this.hasMargin = true,
    required this.color,
    this.width = double.infinity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: hasMargin ? StyleConstants.cardMargin : const EdgeInsets.all(0),
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 10,
            color: ColorTransform.withValue(color, .6).withAlpha(100),
          ),
        ],
        borderRadius:
            BorderRadius.circular(StyleConstants.cardBorderRadiusSize),
        color: Colors.white,
      ),
      child: Center(
        child: child,
      ),
    );
  }
}
