import 'dart:math';

import 'package:flutter/material.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/multiple_choice/multiple_choice_button_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/multiple_choice/multiple_choice_swiping_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';

import 'knowledge_item.dart';

/// Multiple Choice Questions regarding a specific mathematical item.
///
/// Example:
/// QuizMultipleChoiceTexText()
class KnowledgeMultipleChoiceTexText extends KnowledgeItem {
  /// A set of __equivalent__ questions in different formulations. Those formulations
  /// may be used to create the illusion of multiple knowledge items. By default, only
  /// the 1st item will be used
  List<String> questions;

  /// A set of correct answers to the question. They must concern the same item
  List<String> correctChoices;

  /// The wrong choices, can have different __wrong__ meanings
  List<String> incorrectChoices;

  /// The constructor that is used to construct a KnowledgeMultipleChoiceTexText
  /// from the corresponding element in the .wcd document tree. It should __not__
  /// be used to convert any other type of knowledge to this class.
  KnowledgeMultipleChoiceTexText({
    required String id,
    DateTime? due,
    DateTime? lastPracticed,
    int lastInterval = 0,
    required this.questions,
    required this.correctChoices,
    required this.incorrectChoices,
  }) : super(
          id: "knowledgeMultipleChoiceTexText." + id,
          due: due,
          lastInterval: lastInterval,
          lastPracticed: lastPracticed,
        );

  /// The constructor that is used to convert any other type of knowledge to an
  /// instance of KnowledgeMultipleChoiceTexText.
  KnowledgeMultipleChoiceTexText.fromOtherKnowledge({
    required String id,
    DateTime? due,
    DateTime? lastPracticed,
    int lastInterval = 0,
    required this.questions,
    required this.correctChoices,
    required this.incorrectChoices,
  }) : super(
          id: id,
          due: due,
          lastInterval: lastInterval,
          lastPracticed: lastPracticed,
        );

  /// Chooses randomly between a multipleChoiceButtonScreen and a
  /// MultipleChoiceSwipingScreen
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
    int randInt = random.nextInt(2);
    if (randInt == 0) {
      return MultipleChoiceButtonScreen(
        onComplete: onComplete,
        multipleChoice: [this],
        color: color,
      );
    }
    return MultipleChoiceSwipingScreen(
        onComplete: onComplete, multipleChoice: [this], color: color);
  }
}
