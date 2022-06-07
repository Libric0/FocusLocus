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
import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';

class SelectableButton extends StatefulWidget {
  final bool hasCorrectStatement;
  final bool revealed;
  final Widget? child;
  final String? texTextString;
  final VoidCallback? onChanged;
  final bool selected;
  final bool oneLine;
  final double? width;
  final double? height;
  SelectableButton({
    required this.hasCorrectStatement,
    required this.revealed,
    this.width = double.infinity,
    this.oneLine = false,
    this.height,
    this.child,
    this.texTextString,
    this.selected = false,
    this.onChanged,
  })  : assert(
            (child == null || texTextString == null) &&
                !(child == null && texTextString == null),
            "The SelectableButton must have either a child-widget or TexText-string, and not both"),
        super(key: GlobalKey<_SelectableButtonState>());

  @override
  _SelectableButtonState createState() => _SelectableButtonState();
}

class _SelectableButtonState extends State<SelectableButton> {
  bool selected = false;
  @override
  void initState() {
    selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor;

    if (!widget.revealed) {
      // As long as the solution is not revealed, every unselected button is blue
      // and every selected button is amber
      textColor = Colors.black;
    } else {
      // After revealing, the color of a the button is red for correct selections
      // and
      if (widget.hasCorrectStatement) {
        textColor = selected
            ? ColorTransform.withSaturation(Colors.green, .7)
            : ColorTransform.withSaturation(Colors.green, .3);
      } else {
        textColor = selected
            ? Colors.red
            : ColorTransform.withSaturation(Colors.red, .5);
      }
    }
    return FoloButton(
      borderColor:
          selected ? ColorTransform.withSaturation(Colors.blue, 0.7) : null,
      onPressed: () {
        setState(() {
          selected = !selected;
          // Now we trigger what ever should happen when the selection is changed.
          if (widget.onChanged != null) {
            widget.onChanged!();
          }
        });
      },
      useGradient: false,
      enabled: !widget.revealed,
      color: Colors.white,
      width: widget.width,
      height: widget.height,

      // due to the constructer assertions, the texTextString is null iff the
      // child is not null, so one of those cases is always met, and we are null
      // safe
      child: widget.child ??
          (widget.oneLine
              ? FittedBox(
                  child: TexText(
                    rawString: widget.texTextString!,
                    style: TextStyle(color: textColor),
                  ),
                )
              : TexText(
                  rawString: widget.texTextString!,
                  style: TextStyle(color: textColor),
                )),
    );
  }
}
