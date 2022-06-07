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
import 'package:focuslocus/file_io/deck_io.dart';
import 'package:focuslocus/local_storage/deck_metadata_storage.dart';
import 'knowledge_item.dart';

class QuizDeck {
  /// The Name of the deck. It will be displayed on the deckscreen
  String name;

  /// If this variable is true, the getName() function will return a wrapped
  /// texText widget. If it is false, the Name will be a simple text-widget
  bool isNameMath;

  /// The path in the internal file system. It is also used for storing deck
  /// Learning metadata (such as timesPracticed). Will always be of the form
  /// CourseName/01_deck_name.wcd
  String knowledgePath;

  /// The internal id of the deck, it is equivalent to the knowledgePath
  String id;

  /// The variable is used to show how often a deck was practiced
  int _timesPracticed = 0;
  int get timesPracticed => _timesPracticed;
  set timesPracticed(int value) {
    DeckMetadataStorage.setTimesPracticed(id, value);
    _timesPracticed = value;
  }

  /// How often a deck has to be practiced in order to unlock the next deck. May
  /// be automatized if set to null, but now the default is 10
  int minToPractice;

  /// A list of card Types that are contained within this deck
  List<String> cardTypes;

  // The list of quiz-knowledge in this deck. One can use this knowledge to generate
  // a card Type. Has been discontinued, because the knowledge will be loaded on
  // demand before the quiz starts to make many, large decks possible
  //List<QuizKnowledge> knowledge;

  /// The color associated with this deck. They differ to use more modalities and
  /// connect a certain topic to a certain color.
  Color deckColor;

  /// The keywords of the deck. They will be rendered in random positions
  List<String> keywords;

  QuizDeck({
    required String name,
    required String knowledgePath,
    List<String> keywords = const [],
    bool isNameMath = true,
    int timesPracticed = 0,
    int minToPractice = 10,
    Color deckColor = Colors.deepOrange,
  }) : this._(
          name: name,
          id: knowledgePath,
          knowledgePath: knowledgePath,
          keywords: keywords,
          isNameMath: isNameMath,
          timesPracticed: timesPracticed,
          minToPractice: minToPractice,
          deckColor: deckColor,
        );
  QuizDeck._({
    required this.name,
    required this.id,
    required this.knowledgePath,
    this.keywords = const [],
    this.isNameMath = true,
    int timesPracticed = 0,
    this.minToPractice = 10,
    this.cardTypes = const [],
    //this.knowledge = const [],
    this.deckColor = Colors.deepOrange,
  }) {
    _timesPracticed = timesPracticed;
  }

  /// Returns a list of knowledge items. The due items appear in the same order
  /// as in the deck-file. If there is not [amount] due Items, it fills the
  /// remaining spaces with random screens.
  Future<List<KnowledgeItem>> scheduleKnowledgeItems(
    int amount,
  ) async {
    List<KnowledgeItem> knowledgeItems =
        await DeckIO.getKnowledge(knowledgePath);
    List<KnowledgeItem> unscheduledKnowledgeItems =
        List<KnowledgeItem>.from(knowledgeItems);
    List<KnowledgeItem> scheduledKnowledgeItems = [];
    Random random = Random(DateTime.now().hashCode);
    //Pick the doe items with the smallest due date (Just date, not daytime)
    for (int i = 0; i < min(amount, knowledgeItems.length); i++) {
      for (int j = 0; j < unscheduledKnowledgeItems.length; j++) {
        if (unscheduledKnowledgeItems[j].due!.compareTo(DateTime.now()) <= 0) {
          scheduledKnowledgeItems.add(unscheduledKnowledgeItems[j]);
          unscheduledKnowledgeItems.removeAt(j);
          break;
        }
      }
    }
    // If there are less knowledgeItems than ammount, we pick some random
    while (scheduledKnowledgeItems.length < amount) {
      scheduledKnowledgeItems
          .add(knowledgeItems[random.nextInt(knowledgeItems.length)]);
    }
    return scheduledKnowledgeItems.sublist(
        0, min(scheduledKnowledgeItems.length, amount));
  }
}
