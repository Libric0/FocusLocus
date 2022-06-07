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
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A dialog that shows helpful Information about a certain quiz card, e.g. how
/// it works
class QuizCardHelpDialog extends Dialog {
  final List<Widget> children;
  final Color color;
  const QuizCardHelpDialog(
      {required this.children, required this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorTransform.scaffoldBackgroundColor(color),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(children: children),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 10),
            child: FoloButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
