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
