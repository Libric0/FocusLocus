// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:focuslocus/knowledge/deck.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:hexcolor/hexcolor.dart';

/// The representation of a course within an application. It contains a list of
/// decks, has a unique identifier and tracks how many decks have been unlocked
class Course {
  /// The decks within this course
  List<Deck> decks;

  /// The unique identifier of this course. It corresponds to the folder in
  /// which the course-files are stored. In the future it may only be a key
  /// for a key-value database that stores the course-files internally
  final String id;

  //TODO: Enable decks-unlocked functionality
  /// How many decks have been unlocked so far. For the pilot study, this
  /// functionality could not be used, because users were testing the application
  /// close to the exam.
  int decksUnlocked;

  /// The non-unique title for the course.
  late final String title;

  /// The abbreviation of the name of the course. If longer than 6 letters, it
  /// is cropped
  late final String shortTitle;

  /// The language this quiz is is. If no language is given, it is assumed to be
  /// english
  late final String language;

  Course(
      {required this.decks,
      required this.id,
      this.decksUnlocked = 0,
      String? language,
      String? title,
      String? shortTitle}) {
    // Making sure the course has a name, at worst its id
    this.title = title ?? id;

    // Making sure the course has an abbreviation, at worst its id. Both cropped to 6 letters
    if (shortTitle != null) {
      if (shortTitle.length > 6) {
        this.shortTitle = shortTitle.substring(0, 6);
      } else {
        this.shortTitle = shortTitle;
      }
    } else {
      if (id.length > 6) {
        this.shortTitle = id.substring(0, 6);
      } else {
        this.shortTitle = id;
      }
    }
    this.language = language ?? "en";
  }

  factory Course.fromJSON(Map<String, dynamic> jsonObject) {
    if (jsonObject["id"] == null) {
      throw Exception(
          "No id was found for the course ${jsonObject.toString()}");
    }
    if (jsonObject["id"] is! String) {
      throw Exception(
          "The id is not a string for the course ${jsonObject.toString()}");
    }
    if (jsonObject["id"].contains("/")) {
      throw Exception(
          "The id contains a '/' for the course: ${jsonObject.toString()}");
    }
    String id = jsonObject["id"];

    if (jsonObject["title"] != null && jsonObject["title"] is! String) {
      throw Exception(
          "The variable title is something other than a string for the course: $id");
    }
    String? title = jsonObject["title"];

    if (jsonObject["shortTitle"] != null &&
        jsonObject["shortTitle"] is! String) {
      throw Exception(
          "The variable shortTitle is something other than a string for the course: $id");
    }
    String? shortTitle = jsonObject["shortTitle"];

    String? language;
    // TODO: Provide a datastructure for supported languages that automatically updates with the apps translation system
    if ({"en", "de"}.contains(jsonObject["language"])) {
      language = jsonObject["language"];
    }

    List<Color> colors = [];
    if (jsonObject["colors"] != null) {
      if (jsonObject["colors"] is! List) {
        throw Exception(
            "The variable colors is something other than a list for the course: $id");
      }
      for (dynamic color in jsonObject["colors"]) {
        if (color is! String) {
          throw Exception(
              "The list of colors contains something other than a string (for a color) for the course: $id");
        }
        if (color.length != 6) {
          throw Exception(
              "The list of colors contains something other than a correctly formatted hex-color (i.e. of the length 6) for the course: $id");
        }
        for (var char in color.characters.toLowerCase()) {
          if (!const {
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "0",
            "a",
            "b",
            "c",
            "d",
            "e",
            "f"
          }.contains(char)) {
            throw Exception(
                "The list of colors contains something other than a correctly formatted hex-color (i.e. only made up of the letters 1234567890abcdef) for the course $id");
          }
        }
        colors.add(HexColor(color));
      }
    }
    if (jsonObject["decks"] == null) {
      throw Exception(
          "There decks variable does not exist for the course: $id");
    }
    if (jsonObject["decks"] is! List) {
      throw Exception(
          "The decks variable is something other than a list of the course: $id");
    }
    if (jsonObject["decks"].isEmpty) {
      throw Exception("The list of decks is empty for the course: $id");
    }
    List<Deck> decks = [];
    for (int i = 0; i < jsonObject["decks"].length; i++) {
      Color? deckColor;
      if (colors.isNotEmpty) {
        deckColor = ColorTransform.gradientColorMix(
          (i.toDouble() / jsonObject["decks"].length.toDouble()),
          colors,
        );
      }
      decks.add(Deck.fromJSON(
        jsonObject: jsonObject["decks"][i],
        courseId: id,
        deckColor: deckColor,
      ));
    }

    return Course(
      language: language,
      title: title,
      shortTitle: shortTitle,
      decks: decks,
      id: id,
    );
  }
}
