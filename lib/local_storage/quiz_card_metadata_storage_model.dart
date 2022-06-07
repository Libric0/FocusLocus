// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'package:hive/hive.dart';
import 'package:focuslocus/local_storage/quiz_card_metadata_type.dart';
part 'quiz_card_metadata_storage_model.g.dart';

/// Storing the learning information for a quizcard Type. This class should only
/// be used within the LearningMetadata class
@HiveType(typeId: 0)
class QuizCardMetadataStorageModel extends HiveObject {
  /// The type of quizcard this metadata is saved for
  @HiveField(0)
  String type;

  /// How many cards have already been completed (both  successfully and unsuccessfully)
  /// It is basically the denominator for any statistics on the cards.
  @HiveField(1)
  int numberCompleted;

  /// How many seconds have been spent on cards of this type?
  @HiveField(2)
  int sumPlaytime;

  /// How often was a mistake done on that type of card?
  @HiveField(3)
  int numberErrors;

  /// How often was a mistake made by leaving something out?
  /// May only be used for appropriate cards.
  /// An example would be 'forgetting to select one of the correct solutions to a multiple choice question'
  @HiveField(4)
  int numberOmissionErrors;

  /// How often was a mistake made by selecting one to many?
  /// May only be used for appropriate cards.
  /// An example would be 'selecting an incorrect solution to a multiple choice question'
  @HiveField(5)
  int numberFalseCommissions;

  /// How often was this type of card started? This becomes interesting in connection
  /// to numberCompleted. Every card that was started, but not completed means
  /// that there was some kind of interruption. Perhalps use of social media,
  /// perhaps the phone battery died.
  @HiveField(6)
  int numberStarted;

  @HiveField(7)
  int numberSucceeded;

  QuizCardMetadataStorageModel({
    required this.type,
    this.numberStarted = 0,
    this.numberCompleted = 0,
    this.numberFalseCommissions = 0,
    this.numberOmissionErrors = 0,
    this.numberErrors = 0,
    this.sumPlaytime = 0,
    this.numberSucceeded = 0,
  });

  QuizCardMetadataStorageModel.unnamed(
      this.type,
      this.numberCompleted,
      this.sumPlaytime,
      this.numberErrors,
      this.numberOmissionErrors,
      this.numberFalseCommissions,
      this.numberStarted,
      this.numberSucceeded);

  int get(QuizCardMetadataType info) {
    switch (info) {
      case QuizCardMetadataType.numberCompleted:
        return numberCompleted;

      case QuizCardMetadataType.sumPlaytime:
        return sumPlaytime;

      case QuizCardMetadataType.numberErrors:
        return numberErrors;

      case QuizCardMetadataType.numberOmissionErrors:
        return numberOmissionErrors;

      case QuizCardMetadataType.numberCommissionErrors:
        return numberFalseCommissions;

      case QuizCardMetadataType.numberStarted:
        return numberStarted;

      case QuizCardMetadataType.numberSucceeded:
        return numberSucceeded;
    }
  }

  void set(QuizCardMetadataType info, int value) {
    switch (info) {
      case QuizCardMetadataType.numberCompleted:
        numberCompleted = value;
        break;

      case QuizCardMetadataType.sumPlaytime:
        sumPlaytime = value;
        break;

      case QuizCardMetadataType.numberErrors:
        numberErrors = value;
        break;

      case QuizCardMetadataType.numberOmissionErrors:
        numberOmissionErrors = value;
        break;

      case QuizCardMetadataType.numberCommissionErrors:
        numberFalseCommissions = value;
        break;

      case QuizCardMetadataType.numberStarted:
        numberStarted = value;
        break;

      case QuizCardMetadataType.numberSucceeded:
        numberSucceeded = value;
        break;
    }
  }
}
