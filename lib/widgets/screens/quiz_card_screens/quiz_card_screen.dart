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
import 'package:focuslocus/knowledge/knowledge_item.dart';

abstract class QuizCardScreen extends StatefulWidget {
  /// A callback-Function that is called when a card is completed. The Completion
  /// Type indicates how successfully the assignment was completed.
  ///
  /// Different kinds of quizzes may implement different onComplete callbacks.
  final void Function({
    int errors,
    int commissionErrors,
    int omissionErrors,
    required int playtime,
    bool easy,
  }) onComplete;

  /// A list of quiz-knowledge items that may be used for this card. The list could
  /// be implemented as only having one element in the given subclass.
  final List<KnowledgeItem> knowledge;
  final Color color;
  final String cardType;
  const QuizCardScreen({
    required this.onComplete,
    required this.knowledge,
    required this.cardType,
    this.color = Colors.blue,
    Key? key,
  }) : super(key: key);

  ///Shows a help dialog explaining the mechanics of this quiz Card
  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ClipRRect(
        child: Dialog(
          insetPadding: const EdgeInsets.all(0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Text(cardType),
              )),
        ),
      ),
    );
  }
}
