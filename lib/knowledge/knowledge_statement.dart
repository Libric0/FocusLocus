import 'dart:math';

import 'package:flutter/material.dart';
import 'package:focuslocus/knowledge/knowledge_item.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/statement/statement_complete_selection_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/statement/statement_complete_typing_screen.dart';

/// A statement made up of a static part and one dynamic part. The static part,
/// marked in contentItems by being non-empty strings, are always displayed just
/// the same. The dynamic part, the only empty string in contentItems (if not,
/// an error will be thrown), can be filled in with the correct and incorrect
/// fill ins
class KnowledgeStatement extends KnowledgeItem {
  /// The content items. Exactly one item should be "".
  final List<String> contentItems;

  /// The correct replacements for "" in contentItems.
  final List<String> correctFillIns;

  /// The incorrect replacements for "" in contentItems.
  final List<String> incorrectFillIns;

  KnowledgeStatement({
    required String id,
    DateTime? due,
    DateTime? lastPracticed,
    int lastInterval = 0,
    required this.contentItems,
    required this.correctFillIns,
    required this.incorrectFillIns,
  }) : super(
          id: "knowledgeStatement." + id,
          due: due,
          lastPracticed: lastPracticed,
          lastInterval: lastInterval,
        );

  /// Chooses randomly between statementCompleteSelectionScreen and
  /// StatementCompleteTypingScreen
  @override
  QuizCardScreen getRandomScreen(
      Color color,
      Function(
              {int commissionErrors,
              bool easy,
              int errors,
              int omissionErrors,
              required int playtime})
          onComplete,
      BuildContext context) {
    Random random = Random();
    return random.nextBool()
        ? StatementCompleteSelectionScreen(
            statements: [this],
            onComplete: onComplete,
            color: color,
          )
        : StatementCompleteTypingScreen(
            statements: [this], color: color, onComplete: onComplete);
  }
}
