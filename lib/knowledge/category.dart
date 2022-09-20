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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:focuslocus/knowledge/knowledge_item.dart';
import 'package:focuslocus/knowledge/knowledge_multiple_choice.dart';
import 'package:focuslocus/knowledge/multiple_choice.dart';
import 'package:focuslocus/knowledge/universe.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/category/category_bomber_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/category/category_grid_button_select_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';

class Category extends KnowledgeItem {
  /// The universe this category is built upon, i.e. the set of items inside and
  /// outside this category.
  ///
  /// __Example:__ The universe may be a list of all functions, but the category
  /// is the set of all functions that return an int.
  Universe universe;

  /// The questions that may be asked in standard exercises
  List<String> questions;

  /// For different exercises, one may want to provide names to fill them into
  /// the question. For example: "Choose every $categoryNamesSingular[0]." =>
  /// "Choose every NP-hard problem"
  List<String> namesSingular;

  /// For different exercises, one may want to provide names to fill them into
  /// the question. For example: "Only choose $categoryNamesPlural[0]." =>
  /// "Only choose NP-hard problems"
  List<String> namesPlural;

  /// The set of all objects in the universe. It may extend the universe.
  /// For example, if the universe is given by {"red", "blue", "green"} and
  /// inCategory is {"red", "orange", "purple"}, the universe is extended to
  /// {"red", "blue", "green", "orange", "purple"}.
  ///
  /// WARNING: Any typos for overlapping objects will lead to duplicates,
  /// of which one is recognized as in the category, while the other is not.
  Set<String> inCategory;

  Category({
    required String id,
    DateTime? due,
    DateTime? lastPracticed,
    int lastInterval = 0,
    required this.universe,
    required this.questions,
    required this.namesSingular,
    required this.namesPlural,
    required this.inCategory,
  }) : super(
          id: "C." + id,
          due: due,
          lastPracticed: lastPracticed,
          lastInterval: lastInterval,
        );

  Category.fromOtherKnowledge({
    required String id,
    DateTime? due,
    DateTime? lastPracticed,
    int lastInterval = 0,
    required this.universe,
    required this.questions,
    required this.namesSingular,
    required this.namesPlural,
    required this.inCategory,
  }) : super(
          id: id,
          due: due,
          lastPracticed: lastPracticed,
          lastInterval: lastInterval,
        );

  factory Category.fromJSON({
    required String id,
    DateTime? due,
    DateTime? lastPracticed,
    int lastInterval = 0,
    required Map<String, dynamic> jsonObject,
    required Map<String, Universe> universes,
  }) {
    Universe universe;
    if (jsonObject['universe'] is Map) {
      universe = Universe.fromJSON(jsonObject: jsonObject['universe']);
    } else if (jsonObject['universe'] is String) {
      if (!universes.containsKey(jsonObject['universe'])) {
        throw Exception(
            "The given universeId has no defined universe for the Category: $id");
      }
      universe = universes[jsonObject['universe']]!;
    } else if (jsonObject['universe'] == null) {
      throw Exception("No universe was provided for the Category: $id");
    } else {
      throw Exception(
          "The universe-variable is neither a universe nor a valid universeId");
    }

    List<String> questions = [];
    // Checking if questions is a non-empty list or String and assigning the questions
    // variable accordingly
    if (jsonObject['questions'] == null) {
      throw Exception('No questions have been provided for Category: $id');
    } else if (jsonObject['questions'] is String) {
      // We have only one string, so we add it to the list of questions
      questions.add(jsonObject['questions']);
    } else if (jsonObject['questions'] == []) {
      throw Exception('The list of questions is empty for Category: $id');
    } else if (jsonObject['questions'] is List) {
      for (dynamic question in jsonObject['questions']) {
        if (question is! String) {
          throw Exception(
              'The list of questions contains something other than a String for Category: $id');
        }
        questions = jsonObject['questions'];
      }
    } else {
      throw Exception(
          'The \'questions\' value is neither a non-empty list nor a String for Category: $id');
    }

    List<String> namesSingular = [];
    if (jsonObject['namesSingular'] == null) {
      throw Exception(
          "No singular names have been provided for the Category: $id");
    }
    // namesSingular may be entered as List of names or a single name
    if (jsonObject['namesSingular'] is List) {
      for (dynamic name in jsonObject['namesSingular']) {
        if (name is! String) {
          throw Exception(
              "The List namesSingular contains objects other than Strings for the Category: $id");
        }
        namesSingular.add(name);
      }
    } else if (jsonObject['namesSingular'] is String) {
      namesSingular.add(jsonObject['namesSingular']);
    } else {
      throw Exception(
          "The object with the name namesSingular is neither a List nor a string for the Category: $id");
    }

    List<String> namesPlural = [];
    if (jsonObject['namesPlural'] == null) {
      throw Exception(
          "No plural names have been provided for the Category: $id");
    }
    // namesPlural may be entered as List of names or a single name
    if (jsonObject['namesPlural'] is List) {
      for (dynamic name in jsonObject['namesPlural']) {
        if (name is! String) {
          throw Exception(
              "The List namesPlural contains objects other than Strings for the Category: $id");
        }
        namesPlural.add(name);
      }
    } else if (jsonObject['namesPlural'] is String) {
      namesPlural.add(jsonObject['namesPlural']);
    } else {
      throw Exception(
          "The object with the name namesPlural is not a List for the Category: $id");
    }

    Set<String> inCategory = {};
    if (jsonObject['inCategory'] == null) {
      throw Exception(
          "No object named inCategory was provided for the Category: $id");
    }
    if (jsonObject['inCategory'] is List) {
      for (dynamic object in jsonObject['inCategory']) {
        if (object is! String) {
          throw Exception(
              "The object ${object.toString()} in the inCategory list is not a string for Category: $id");
        }
        inCategory.add(object);
      }
    }
    // Adding all objects in the category to the universe. This can make the
    // workflow a bit easier, but one has to make sure that each object is
    // written in a single way. Otherwise duplicates will occur.
    //TODO: Check whether this changes the universe for other cards using this category as well
    universe.objects = universe.objects.union(inCategory);
    return Category(
      id: id,
      universe: universe,
      questions: questions,
      namesSingular: namesSingular,
      namesPlural: namesPlural,
      inCategory: inCategory,
      due: due,
      lastInterval: lastInterval,
      lastPracticed: lastPracticed,
    );
  }

  Set<String> get notInCategory => universe.objects.difference(inCategory);

  /// Returns a random quizcard screen for that category. Quizcard screens that
  /// are specially made for categories are preferred.
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
    Random _random = Random(DateTime.now().hashCode);
    if (_random.nextInt(4) > 0) {
      if (_random.nextBool()) {
        return CategoryBomberScreen(
          categories: [this],
          onComplete: onComplete,
          color: color,
        );
      } else {
        return CategoryGridButtonSelect(
          categories: [this],
          onComplete: onComplete,
          color: color,
        );
      }
    } else {
      // One way to ask a category question is by using a simple yes/no format.
      // For this, we return a multipleChoiceTexText screen.
      List<String> correctChoices = [for (String object in inCategory) object];
      List<String> incorrectChoices = [
        for (String object in universe.objects.difference(inCategory)) object
      ];
      incorrectChoices
          .removeWhere((element) => correctChoices.contains(element));
      MultipleChoice convertedKnowledge = MultipleChoice.fromOtherKnowledge(
        id: id,
        questions: [
          AppLocalizations.of(context)!
              .knowledgeCategoryStandardQuestion(namesPlural[0])
        ],
        correct: correctChoices,
        incorrect: incorrectChoices,
        due: due,
        lastInterval: lastInterval,
        lastPracticed: lastPracticed,
      );
      return convertedKnowledge.getRandomScreen(color, onComplete, context);
    }
  }
}
