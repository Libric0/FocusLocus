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
import 'package:focuslocus/local_storage/quiz_card_metadata_storage_model.dart';

/// Singleton giving access to all quizcard metadata objects.
class LearningMetadataStorage {
  /// The box containing all the metadata. Yes, I am aware that with Hive.box('playground)
  /// You can get access to the box. However, this should be the primary interface for it
  static Box<QuizCardMetadataStorageModel>? _quizCardMetadataBox;
  static LearningMetadataStorage? _instance;

  LearningMetadataStorage._();

  /// Should only be called once per run: Creates singleton instance and opens
  /// The Hive box.
  static Future<void> init() async {
    _instance = LearningMetadataStorage._();
    _quizCardMetadataBox = await Hive.openBox('QuizCardMetadata');
  }

  /// Returns the current value of some QuizCardMetadata given the quizCardType
  /// and which info should be considered.
  static int get(String quizCardType, QuizCardMetadataType info) {
    _initIfNull();
    QuizCardMetadataStorageModel metadata = _getMetadata(quizCardType);

    return metadata.get(info);
  }

  /// Sets the value of some QuizCardMetadata
  static void set(String quizCardType, QuizCardMetadataType info, int value) {
    _initIfNull();
    QuizCardMetadataStorageModel metadata = _getMetadata(quizCardType);
    metadata.set(info, value);
    metadata.save();
  }

  /// Adds a value to the currently stored value of some QuizCardMetadata
  static void add(String quizCardType, QuizCardMetadataType info, int value) {
    _initIfNull();
    QuizCardMetadataStorageModel metadata = _getMetadata(quizCardType);
    metadata.set(info, metadata.get(info) + value);
    metadata.save();
  }

  /// Increments the currently stored value of some QuizCardMetadata
  static void increment(String quizCardType, QuizCardMetadataType info) {
    _initIfNull();
    set(quizCardType, info, get(quizCardType, info) + 1);
  }

  /// Decrements the currently stored value of some QuizCardMetadata
  static void decrement(String quizCardType, QuizCardMetadataType info) {
    _initIfNull();
    int currentValue = get(quizCardType, info);

    if (currentValue > 0) {
      set(quizCardType, info, currentValue - 1);
    }
  }

  static QuizCardMetadataStorageModel _getMetadata(String quizCardType) {
    _initIfNull();
    QuizCardMetadataStorageModel? metadata =
        _quizCardMetadataBox?.get(quizCardType);

    if (metadata == null) {
      metadata = QuizCardMetadataStorageModel(type: quizCardType);
      _quizCardMetadataBox?.put(quizCardType, metadata);
    }
    return metadata;
  }

  static void _initIfNull() async {
    if (_instance == null || _quizCardMetadataBox == null) {
      await init();
    }
  }

  static List<String> getAllCardTypes() {
    _initIfNull();
    return _quizCardMetadataBox!.keys.whereType<String>().toList();
  }
}
