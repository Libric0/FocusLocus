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
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class Statement extends KnowledgeItem {
  final List<dynamic> content;

  Statement({
    required String id,
    required this.content,
    int lastInterval = 0,
    DateTime? due,
    DateTime? lastPracticed,
  }) : super(
            id: id,
            lastInterval: lastInterval,
            due: due,
            lastPracticed: lastPracticed);

  factory Statement.fromJSON({
    required Map<String, dynamic> jsonObject,
    required String id,
    int lastInterval = 0,
    DateTime? due,
    DateTime? lastPracticed,
  }) {
    List<dynamic> content = [];
    // Checking if the provided list of contentItems is a non-empty list
    if (jsonObject["content"] is! List) {
      if (jsonObject["content"] == null) {
        throw Exception(
            "No content has been provided for statement ${jsonObject.toString()}");
      } else {
        throw Exception(
            "\"content\"-variable is not a list for statement ${jsonObject.toString()}");
      }
    }
    if (jsonObject["content"].length < 2) {
      throw Exception(
          "List of content does not contain at least 2 items for statement ${jsonObject.toString()}");
    }

    /// All statements must have a completable. If this is false after the
    /// for loop completes, an exception is thrown
    bool hasCompletable = false;
    for (dynamic contentItem in jsonObject["content"]) {
      if (contentItem is String) {
        content.add(contentItem);
      } else if (contentItem is Map<String, dynamic>) {
        content.add(Completable.fromJSON(contentItem));
        hasCompletable = true;
      }
    }
    if (!hasCompletable) {
      throw Exception(
          "No completable provided for statement ${jsonObject.toString()}");
    }
    return Statement(
        id: id,
        content: content,
        lastInterval: lastInterval,
        due: due,
        lastPracticed: lastPracticed);
  }

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
    // TODO: implement getRandomScreen
    throw UnimplementedError();
  }

  @override
  String toString() {
    List<String> contentStrings = [
      for (dynamic contentItem in content) contentItem.toString()
    ];
    return "{$runtimeType, id: $id, content: $contentStrings}";
  }

  List<Completable> get completables {
    return content.whereType<Completable>().toList();
  }
}

class Completable {
  /// All correct FillIns for this Completable. The user is supposed to enter
  /// one of those. At least one has to be provided and visible.
  final List<_FillIn> correct;

  /// All incorrect FillIns. Can be empty.
  final List<_FillIn> incorrect;

  /// The weight of this completable. If the weight is higher, it is more likely
  /// that this completable is chosen for an exercise. May be used if one keyword
  /// within the statement is more important than the others.
  final int weight;

  const Completable({
    required this.correct,
    required this.incorrect,
    this.weight = 1,
  });

  /// Turns a decoded JSON object into a FillIn. Also handles expected errors
  ///
  /// Can throw exceptions if:
  /// - No list of correct FillIns has been provided (variable name: `"correct"`)
  /// - The list of correct FillIns is empty
  /// - The variable `"correct"` or `"incorrect"` has a type different from a list or string
  factory Completable.fromJSON(Map<String, dynamic> jsonObject) {
    List<_FillIn> correct = [];

    // Checking if the correct FillIns list has a valid value
    if (jsonObject["correct"] is! List) {
      if (jsonObject["correct"] == null) {
        throw Exception(
            "List of correct fillIns is missing for the completable ${jsonObject.toString()}");
      } else if (jsonObject["correct"] is String) {
        // Only a string
        correct.add(_FillIn.fromJSON(jsonObject["correct"]));
      } else {
        throw Exception(
            "\"correct\" variable is not a list for completable ${jsonObject.toString()}");
      }
    } else if (jsonObject["correct"].isEmpty) {
      throw Exception(
          "No correct solution for completable ${jsonObject.toString()}");
    } else {
      // Generating List of correct FillIns
      for (dynamic fillIn in jsonObject["correct"]) {
        correct.add(_FillIn.fromJSON(fillIn));
      }
    }

    List<_FillIn> incorrect = [];
    // Checking if the incorrect FillIns list or string has a valid value.
    // Empty Lists, strings and null are allowed
    if (jsonObject["incorrect"] is String) {
      incorrect.add(_FillIn.fromJSON(jsonObject["incorrect"]));
    } else {
      if (jsonObject["incorrect"] is! List && jsonObject["incorrect"] != null) {
        throw Exception(
            "\"incorrect\" variable is neither a list, string or null for completable ${jsonObject.toString()}");
      }

      if (jsonObject["incorrect"] is List) {
        // Generating List of incorrect FillIns
        for (dynamic fillIn in jsonObject["incorrect"]) {
          incorrect.add(_FillIn.fromJSON(fillIn));
        }
      }
    }

    int weight = 1;

    // The weight variable may be null, but we throw an exception if the value
    // is not a positive integer value
    if (jsonObject["weight"] != null) {
      if (jsonObject["weight"] is int) {
        if (jsonObject["weight"] > 0) {
          weight = jsonObject["weight"];
        } else {
          throw Exception(
              "\"weight\" variable is not a positive number for completable ${jsonObject.toString()}");
        }
      } else {
        throw Exception(
            "\"weight\" variable does not have an integer type for completable ${jsonObject.toString()}");
      }
    }
    return Completable(correct: correct, incorrect: incorrect, weight: weight);
  }

  bool fitsInput(String userInput) {
    // Finding the best ratio for correctFillIns
    int highestRatioCorrect = 0;
    for (_FillIn currentFillIn in correct) {
      highestRatioCorrect =
          max(highestRatioCorrect, currentFillIn.equalityRatio(userInput));
    }

    // Finding the best ratio for incorrectFillIns
    int highestRatioIncorrect = 0;
    for (_FillIn currentFillIn in incorrect) {
      highestRatioIncorrect =
          max(highestRatioIncorrect, currentFillIn.equalityRatio(userInput));
    }

    // Comparing the best ratio for correct and incorrect fillIns. If an
    // incorrect one fits better, the user most likely entered a wrong input
    // or did so many spelling mistakes that it morped into something
    // undecernable from an incorrect answer.
    if (highestRatioIncorrect >= highestRatioCorrect) {
      return false;
    }

    // If the input does not fit any correct FillIn up to a tolerance of 90%,
    // it is safe to assume that the user gave an answer that was not expeced.
    // At some point, too many spelling mistakes should be punished as well.
    if (highestRatioCorrect < 90) {
      return false;
    }

    return true;
  }
}

@immutable
class _FillIn {
  /// The type of the FillIn. This determines how the fillIn's function will
  /// behave. For example, code will be displayed in a monospace font, and math
  /// will use a mathField instead of a textField for typing.
  ///
  /// `_FillInType.text` by default
  final _FillInType type;

  /// Whether the FillIn is visible or not. If it is visible, it can be shown
  /// as a possible choice when the user is to pick the correct FillIn.
  /// If the content is not something to be shown, but should be accepted
  /// when typed in, set this to false. An example for this case would be:
  ///
  /// - a^{n+1} (visible)
  /// - a^n+1 (invisible, but one knows what was meant)
  ///
  /// `true` by default
  final bool visible;

  /// Whether the case should be regarded when comparing this fillIn to a user
  /// input. An example where this can be useful is when both n and N are
  /// variables in a theorem, but with different semantics.
  ///
  /// `false` by default
  final bool caseSensitive;

  /// The content of the FillIn. I.e. what will be displayed or what the user
  /// input will be compared against. Has no default value and must always be
  /// provided
  final String content;

  const _FillIn({
    required this.content,
    this.type = _FillInType.text,
    this.visible = true,
    this.caseSensitive = false,
  });

  /// Turns a decoded JSON object into a FillIn. Also handles expected errors.
  ///
  /// If the jsonObject is a string, it returns a text-fillIn that is visible
  /// and not case-sensitive
  factory _FillIn.fromJSON(dynamic jsonObject) {
    // Strings
    if (jsonObject is String) {
      return _FillIn(content: jsonObject);
    }

    String content = jsonObject["content"];
    // Type
    _FillInType type = _FillInType.text;
    try {
      switch (jsonObject[type]) {
        case "math":
          {
            type = _FillInType.math;
            break;
          }
        case "code":
          {
            type = _FillInType.code;
            break;
          }
      }
    } catch (e) {
      // No type was provided. We don't have to do any error Handling, this
      // is expected.
    }

    // Visibility
    bool visible = true;
    try {
      visible = jsonObject["visible"];
    } on TypeError catch (e) {
      if (jsonObject["visible"] != null) {
        // ignore: avoid_print
        print(
            "A non-boolean value was given for the visibility of the FillIn for {$content}. Resorting to default [true].");
      }
      // We arrive here if no visibility was provided. This is not an error,
      // and we still resort to the default
    }

    bool caseSensitive = false;
    try {
      caseSensitive = jsonObject["caseSensitive"];
    } on TypeError catch (e) {
      if (jsonObject["caseSensitive"] != null) {
        // ignore: avoid_print
        print(
            "A non-boolean value was given for the case-sensitivity of the FillIn for {$content}. Resorting to default [false].");
      }
      // We arrive here if no case-sensitivity was provided. This is not an error,
      // and we still resort to the default
    }

    return _FillIn(
      content: content,
      caseSensitive: caseSensitive,
      type: type,
      visible: visible,
    );
  }

  /// Compares the [userInput] to the content of this FillIn based on the type
  /// of the fillIn
  int equalityRatio(String userInput) {
    String compareContent = content;
    String compareOther = userInput;
    if (!caseSensitive) {
      compareContent = compareContent.toLowerCase();
      compareOther = compareOther.toLowerCase();
    }
    return ratio(compareContent, compareOther);
  }
}

enum _FillInType { text, math, code }
