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
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';

import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';

class QuestionCard extends StatelessWidget {
  /// The question in TexText notation
  final String question;
  final Color color;
  const QuestionCard({
    required this.question,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FoloCard(
      color: color,
      child: Center(
        child: TexText(
          rawString: question,
          style: TextStyle(
            color: ColorTransform.textColor(color),
          ),
        ),
      ),
    );
  }
}
