import 'package:flutter/material.dart';

/// A linear progress indicator that has been altered to fit into the theming
/// of FocusLocus
class FoloProgressIndicator extends StatelessWidget {
  final Color color;
  final Color backgroundColor;
  final double value;
  const FoloProgressIndicator(
      {required this.color,
      this.backgroundColor = Colors.white,
      required this.value,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: LinearProgressIndicator(
        color: color,
        backgroundColor: backgroundColor,
        minHeight: 20,
        value: value,
      ),
    );
  }
}
