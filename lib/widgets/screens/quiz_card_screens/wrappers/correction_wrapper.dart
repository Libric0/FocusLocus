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
import 'package:focuslocus/widgets/quiz_card_items/correction.dart';

class CorrectionWrapper extends StatelessWidget {
  final Widget child;
  final bool revealed;
  final double height;
  final int errors;
  final int commissionErrors;
  final int omissionErrors;
  final int playtime;
  final String? correctMessage;
  final String? incorrectMessage;
  final bool easy;
  final String quizCardID;
  final Function({
    int errors,
    int commissionErrors,
    int omissionErrors,
    required int playtime,
    bool easy,
  }) onComplete;
  const CorrectionWrapper(
      {required this.child,
      required this.revealed,
      this.height = 140,
      this.errors = 0,
      this.commissionErrors = 0,
      this.omissionErrors = 0,
      required this.onComplete,
      this.correctMessage,
      this.incorrectMessage,
      this.easy = false,
      required this.playtime,
      required this.quizCardID,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          child: Correction(
            onComplete: onComplete,
            playtime: playtime,
            commissionErrors: commissionErrors,
            correctMessage: correctMessage,
            easy: easy,
            errors: errors,
            height: height,
            incorrectMessage: incorrectMessage,
            omissionErrors: omissionErrors,
            revealed: revealed,
            quizCardID: quizCardID,
          ),
        )
      ],
    );
  }
}
