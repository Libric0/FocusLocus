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
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';

/// The class al knowledgeItems inherit from.
abstract class KnowledgeItem {
  /// The unique identifier that is used as a key in the hive-box to store and
  /// access scheduling information on the disk
  String id;

  /// How many days the card was delayed in the last spaced-repetition interval
  int lastInterval;

  /// If this date is surpassed, the knowledge-item will be preferred in the
  /// scheduler
  DateTime? due;

  // The date the card was practiced for the last time
  DateTime? lastPracticed;

  KnowledgeItem({
    required this.id,
    this.lastInterval = 0,
    this.due,
    this.lastPracticed,
  }) {
    // We still want to be null-safe, this is why we assign default values
    // to due and lastPracticed
    lastPracticed ??= DateTime.fromMicrosecondsSinceEpoch(0);
    due ??= DateTime.now();
  }

  /// Returns a random quiz-card screen generated from this knowledge-item.
  QuizCardScreen getRandomScreen(
      Color color,
      Function(
              {int commissionErrors,
              bool easy,
              int errors,
              int omissionErrors,
              required int playtime})
          onComplete,
      BuildContext context);
}
