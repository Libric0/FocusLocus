// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'package:focuslocus/local_storage/deck_metadata_storage_model.dart';
import 'package:hive/hive.dart';

/// The storage for all deck metadata. Right now, it only takes care of
/// how many times a deck was practiced.
class DeckMetadataStorage {
  static DeckMetadataStorage? _instance;
  static Box<DeckMetadataStorageModel>? _deckStorage;

  DeckMetadataStorage._();
  static Future<void> init() async {
    _instance ??= DeckMetadataStorage._();
    if (!Hive.isBoxOpen("DeckMetadata")) {
      _deckStorage = await Hive.openBox("DeckMetadata");
    }
  }

  static int getTimesPracticed(String deckId) {
    _initIfNull();
    DeckMetadataStorageModel? deck = _deckStorage!.get(deckId);
    if (deck == null) {
      deck = DeckMetadataStorageModel();
      _deckStorage!.put(deckId, deck);
    }
    return deck.timesPracticed;
  }

  // static void incrementTimesPracticed(String deckId) {
  //   _initIfNull();
  //   DeckMetadataStorageModel? deck = _deckStorage!.get(deckId);
  //   if (deck != null) {
  //     deck.timesPracticed++;
  //     deck.save();
  //   } else {
  //     deck = DeckMetadataStorageModel(timesPracticed: 1);
  //     _deckStorage!.put(deckId, deck);
  //   }
  // }

  static void setTimesPracticed(String deckId, int timesPracticed) {
    _initIfNull();
    DeckMetadataStorageModel? deck = _deckStorage!.get(deckId);
    if (deck != null) {
      deck.timesPracticed = timesPracticed;
      deck.save();
    } else {
      deck = DeckMetadataStorageModel(timesPracticed: timesPracticed);
      _deckStorage!.put(deckId, deck);
    }
  }

  static void _initIfNull() {
    if (_instance == null) {
      init();
    }
  }
}
