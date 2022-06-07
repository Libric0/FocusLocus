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
import 'package:focuslocus/knowledge/math_object.dart';
import 'package:focuslocus/knowledge/math_universe.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/category/category_bomber_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/category/category_grid_button_select_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'knowledge_multiple_choice.dart';

/// The representation of a category knowledge item.
class KnowledgeCategory extends KnowledgeItem {
  /// The universe this category is built upon, i.e. the set of items inside and
  /// outside this category.
  ///
  /// __Example:__ The universe may be a list of all functions, but the category
  /// is the set of all functions that return an int.
  MathUniverse universe;

  /// The questions that may be asked in standard exercises
  List<String> questions;

  /// For different exercises, one may want to provide names to fill them into
  /// the question. For example: "Choose every $categoryNamesSingular[0]." =>
  /// "Choose every NP-hard problem"
  List<String> categoryNamesSingular;

  /// For different exercises, one may want to provide names to fill them into
  /// the question. For example: "Only choose $categoryNamesPlural[0]." =>
  /// "Only choose NP-hard problems"
  List<String> categoryNamesPlural;

  /// The list of all indices that correspond to an item in the universe.
  List<int> indicesInCategory;

  /// The same as questions but for the dual category, if it exists
  List<String> dualQuestions;

  /// For different exercises, one may want to provide names to fill them into
  /// the question. For example: "Choose every $dualCategoryNamesSingular[0]." =>
  /// "Choose every co-NP-hard problem"
  List<String> dualCategoryNamesSingular;

  /// For different exercises, one may want to provide names to fill them into
  /// the question. For example: "Only choose $dualCategoryNamesPlural[0]." =>
  /// "Only choose co-NP-hard problems"
  List<String> dualCategoryNamesPlural;

  /// Some categories have categories that are analogous in a way, but practically
  /// the opposite in another. An example would be the set of all logical formulas
  /// that have a satisfying variable assignment as the category, and the
  /// logical formulas that are tautologies as the dual category. The difference
  /// just lies in the quantifier: Existence or Universal. By taking the complement
  /// of each formula, we also flip the quantifier. In that sense, those categories
  /// are dual.
  List<int> indicesInDualCategory;

  KnowledgeCategory({
    required this.universe,
    required this.questions,
    required this.indicesInCategory,
    required this.categoryNamesSingular,
    required this.categoryNamesPlural,
    this.indicesInDualCategory = const [],
    this.dualCategoryNamesSingular = const [],
    this.dualCategoryNamesPlural = const [],
    this.dualQuestions = const [],
    required String id,
    int lastInterval = 0,
    DateTime? due,
    DateTime? lastPracticed,
  }) : super(
          id: "knowledgeCategory." + id,
          lastInterval: lastInterval,
          due: due,
          lastPracticed: lastPracticed,
        );

  // Is true iff the dual category contains elements.
  bool get hasDualCategory => indicesInDualCategory.isNotEmpty;

  /// Returns all indices that are not in the indicesInCategory-List
  List<int> get indicesNotInCategory {
    return [
      for (int i = 0; i < universe.size; i++)
        if (!indicesInCategory.contains(i)) i
    ];
  }

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
      List<String> correctChoices = [
        for (int index in indicesInCategory) universe.texTextRawStringAt(index)
      ];
      List<String> incorrectChoices = [
        for (MathObject mathObject in universe) mathObject.rawString
      ];
      incorrectChoices
          .removeWhere((element) => correctChoices.contains(element));
      KnowledgeMultipleChoiceTexText convertedKnowledge =
          KnowledgeMultipleChoiceTexText.fromOtherKnowledge(
        id: id,
        questions: [
          AppLocalizations.of(context)!
              .knowledgeCategoryStandardQuestion(categoryNamesPlural[0])
        ],
        correctChoices: correctChoices,
        incorrectChoices: incorrectChoices,
        due: due,
        lastInterval: lastInterval,
        lastPracticed: lastPracticed,
      );
      return convertedKnowledge.getRandomScreen(color, onComplete, context);
    }
  }
}
