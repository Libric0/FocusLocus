// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:focuslocus/knowledge/knowledge_item.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/multiple_choice/multiple_choice_button_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/multiple_choice/multiple_choice_swiping_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';

class MultipleChoice extends KnowledgeItem {
  /// A set of __equivalent__ questions in different formulations. Those formulations
  /// may be used to create the illusion of multiple knowledge items.
  List<String> questions;

  /// A set of correct answers to the question. They must contain at least one item
  List<String> correct;

  /// The wrong choices, can have different __wrong__ meanings. Must contain at least one item
  List<String> incorrect;

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
      onComplete: onComplete,
      multipleChoice: [this],
      color: color,
    );
  }

  MultipleChoice({
    required String id,
    DateTime? due,
    DateTime? lastPracticed,
    int lastInterval = 0,
    required this.questions,
    required this.correct,
    required this.incorrect,
  }) : super(
          id: "M." + id,
          due: due,
          lastInterval: lastInterval,
          lastPracticed: lastPracticed,
        );

  MultipleChoice.fromOtherKnowledge({
    required String id,
    DateTime? due,
    DateTime? lastPracticed,
    int lastInterval = 0,
    required this.questions,
    required this.correct,
    required this.incorrect,
  }) : super(
          id: id,
          due: due,
          lastInterval: lastInterval,
          lastPracticed: lastPracticed,
        );

  factory MultipleChoice.fromJSON({
    required Map<String, dynamic> jsonObject,
    required String id,
    int lastInterval = 0,
    DateTime? due,
    DateTime? lastPracticed,
  }) {
    // questions
    List<String> questions = [];

    // Checking if questions is a non-empty list or String and assigning the questions
    // variable accordingly
    if (jsonObject['questions'] == null) {
      throw Exception(
          'No questions have been provided for Multiple-Choice Item: $id');
    } else if (jsonObject['questions'] is String) {
      // We have only one string, so we add it to the list of questions
      questions.add(jsonObject['questions']);
    } else if (jsonObject['questions'] == []) {
      throw Exception(
          'The list of questions is empty for Multiple-Choice Item: $id');
    } else if (jsonObject['questions'] is List) {
      for (dynamic question in jsonObject['questions']) {
        if (question is! String) {
          throw Exception(
              'The list of questions contains something other than a String for Multiple-Choice Item: $id');
        }
        questions = jsonObject['questions'];
      }
    } else {
      throw Exception(
          'The \'questions\' value is neither a non-empty list nor a String');
    }

    // correct answers
    List<String> correct = [];
    // Checking if correct is a non-empty list or String and assigning the correct answers
    // variable accordingly
    if (jsonObject['correct'] == null) {
      throw Exception(
          'No correct answers have been provided for Multiple-Choice Item: $id');
    } else if (jsonObject['correct'] is String) {
      // We have only one string, so we add it to the list of correct answers
      correct.add(jsonObject['correct']);
    } else if (jsonObject['correct'] == []) {
      throw Exception(
          'The list of correct answers is empty for Multiple-Choice Item: $id');
    } else if (jsonObject['correct'] is List) {
      for (dynamic answer in jsonObject['correct']) {
        if (answer is! String) {
          throw Exception(
              'The list of correct answers contains something other than a String for Multiple-Choice Item: $id');
        }
        correct = jsonObject['correct'];
      }
    } else {
      throw Exception(
          'The \'correct\' value is neither a non-empty list nor a String');
    }

    // incorrect answers
    List<String> incorrect = [];
    // Checking if correct is a non-empty list or String and assigning the correct answers
    // variable accordingly
    if (jsonObject['incorrect'] == null) {
      throw Exception(
          'No incorrect answers have been provided for Multiple-Choice Item: $id');
    } else if (jsonObject['incorrect'] is String) {
      // We have only one string, so we add it to the list of correct answers
      incorrect.add(jsonObject['incorrect']);
    } else if (jsonObject['incorrect'] == []) {
      throw Exception(
          'The list of incorrect answers is empty for Multiple-Choice Item: $id');
    } else if (jsonObject['incorrect'] is List) {
      for (dynamic answer in jsonObject['incorrect']) {
        if (answer is! String) {
          throw Exception(
              'The list of incorrect answers contains something other than a String for Multiple-Choice Item: $id');
        }
        incorrect = jsonObject['incorrect'];
      }
    } else {
      throw Exception(
          'The \'incorrect\' value is neither a non-empty list nor a String');
    }

    return MultipleChoice(
      id: id,
      questions: questions,
      correct: correct,
      incorrect: incorrect,
      due: due,
      lastPracticed: lastPracticed,
      lastInterval: lastInterval,
    );
  }
}
