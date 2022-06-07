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

/// An animated button that is more stimulating and game-like than the standard
/// material button.
class FoloButton extends StatefulWidget {
  final Widget child;
  final Color color;
  @Deprecated("It just sets width to double.infinity. Do that instead")
  final bool shouldStretch;
  final VoidCallback onPressed;
  final bool enabled;
  final double? width;
  final double? height;
  final Duration animationDuration;
  final Color? borderColor;
  final double elevation;
  final bool useGradient;
  const FoloButton({
    required this.child,
    this.enabled = true,
    this.color = Colors.blue,
    this.shouldStretch = false,
    required this.onPressed,
    this.width = 200,
    this.height,
    this.animationDuration = const Duration(milliseconds: 25),
    this.borderColor,
    this.elevation = 10,
    this.useGradient = true,
    Key? key,
  }) : super(key: key);

  @override
  State<FoloButton> createState() => _FoloButtonState();
}

class _FoloButtonState extends State<FoloButton> {
  double elevationState = 0;
  bool firstState = true;
  bool shiftingDown = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (firstState) {
      elevationState = widget.elevation;
      firstState = false;
    }

    TextStyle buttonTextStyle =
        Theme.of(context).textTheme.button ?? const TextStyle();
    return GestureDetector(
      child: TweenAnimationBuilder(
          tween: Tween<double>(begin: elevationState, end: elevationState),
          onEnd: () {
            if (widget.enabled) {
              if (shiftingDown) {
                setState(() {
                  shiftingDown = false;
                  elevationState = widget.elevation;
                });
              } else {
                widget.onPressed();
              }
            }
          },
          curve: Curves.linear,
          duration: widget.animationDuration,
          builder: (context, double elevationValue, _) {
            return DefaultTextStyle(
              style: Theme.of(context).textTheme.button!,
              child: Container(
                margin: EdgeInsets.only(
                  top: 10 - elevationValue,
                  bottom: elevationValue - 5,
                ),
                child: DefaultTextStyle(
                    style: buttonTextStyle.copyWith(color: Colors.white),
                    child: Center(child: widget.child)),
                decoration: BoxDecoration(
                    border: widget.useGradient
                        ? null
                        : Border.all(
                            width: 5,
                            color: widget.borderColor != null
                                ? widget.borderColor!
                                : ColorTransform.darker(widget.color,
                                    factor: 0.8)),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    gradient: widget.useGradient
                        ? LinearGradient(
                            colors: [
                              widget.color,
                              ColorTransform.gradientColor(widget.color)
                            ],
                          )
                        : null,
                    color: widget.color,
                    boxShadow: [
                      BoxShadow(
                          color: widget.borderColor != null
                              ? ColorTransform.darker(widget.borderColor!,
                                  factor: 0.6 / 0.8)
                              : ColorTransform.darker(widget.color,
                                  factor: 0.6),
                          offset: Offset(0, elevationValue))
                    ]),
                // ignore: deprecated_member_use_from_same_package
                width: widget.shouldStretch ? double.infinity : widget.width,
                height: widget.height,
              ),
            );
          }),
      onTap: () {
        if (widget.enabled) {
          setState(() {
            shiftingDown = true;
            elevationState = widget.elevation / 2;
          });

          //widget.onPressed();
        }
      },
    );
  }
}
