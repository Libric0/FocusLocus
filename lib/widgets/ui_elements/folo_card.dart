// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

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
