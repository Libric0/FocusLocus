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

class Deck {
  /// The Name of the deck. It will be displayed on the deckscreen
  String name;

  /// The path in the internal file system. It is also used for storing deck
  /// Learning metadata (such as timesPracticed). Will always be of the form
  /// CourseName/01_deck_name.wcd
  /// It is just syntactical sugar and equivalent to id
  String get knowledgePath => id;

  /// The internal id of the deck
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

  Deck({
    required String title,
    required String id,
    required String courseId,
    List<String> keywords = const [],
    bool isNameMath = true,
    int timesPracticed = 0,
    int minToPractice = 10,
    Color deckColor = Colors.deepOrange,
  }) : this._(
          name: title,
          id: "$courseId/$id",
          keywords: keywords,
          timesPracticed: timesPracticed,
          minToPractice: minToPractice,
          deckColor: deckColor,
        );
  Deck._({
    required this.name,
    required this.id,
    this.keywords = const [],
    int timesPracticed = 0,
    this.minToPractice = 10,
    this.cardTypes = const [],
    //this.knowledge = const [],
    this.deckColor = Colors.deepOrange,
  }) {
    _timesPracticed = timesPracticed;
  }

  factory Deck.fromJSON(
      {required Map<String, dynamic> jsonObject,
      required String courseId,
      Color? deckColor}) {
    if (jsonObject["id"] == null) {
      throw Exception(
          "No id has been provided for the deck: ${jsonObject.toString()}");
    }
    if (jsonObject["id"] is! String) {
      throw Exception(
          "The id variable contains something other than a string for the deck ${jsonObject.toString()}");
    }
    if (jsonObject["id"] == "") {
      throw Exception(
          "The id variable contains the empty string for the deck ${jsonObject.toString()}");
    }
    if (jsonObject["id"].contains("/")) {
      throw Exception(
          "The id contains the illegal character '/' for the deck: ${jsonObject.toString()}");
    }
    String id = jsonObject["id"];
    if (jsonObject["title"] != null && jsonObject["title"] is! String) {
      throw Exception(
          "The variable title is something other than a string for the deck: $id");
    }
    String? title = jsonObject["title"];

    return Deck(
      title: title ?? id,
      id: id,
      courseId: courseId,
      deckColor: deckColor ?? Colors.red,
    );
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
