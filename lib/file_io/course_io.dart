// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hexcolor/hexcolor.dart';
import 'package:focuslocus/knowledge/course.dart';
import 'package:focuslocus/knowledge/deck.dart';
import 'package:focuslocus/local_storage/course_metadata_storage.dart';
import 'package:focuslocus/local_storage/deck_metadata_storage.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:xml/xml.dart';

import 'package:flutter/material.dart';

/// This class is used to read course files (.wcc). Those are used to create the
/// course overview. In later work, it will read from the devices filesystem and
/// not the binary file. For now, this suffices.
class CourseIO {
  /// Loads a .wcc file from the disk and turns it into a XmlDocument object
  /// that can be parsed in other methods
  static Future<String> getCourseString(String courseName) async {
    String fullPath = 'assets/deck_data/' + courseName + '/';
    String courseString = await rootBundle.loadString(fullPath + 'course');

    return courseString.trim();
  }

  /// Looks up all places where courses can exist and retrives a list of all course IDs
  static Future<List<String>> getAllCourseIDs() async {
    return Future<List<String>>(
      () => [
        'BuK',
        'Logra',
        'KnowledgeRepresentation',
        'Effi',
        'testcourse',
        "IDS"
      ],
    );
  }

  /// Returns all existing quiz-courses
  static Future<List<Course>> getAllCourses() async {
    List<String> courseIDs = await getAllCourseIDs();
    List<Course> ret = [];
    for (String courseID in courseIDs) {
      try {
        Course course = await getCourse(courseID);
        ret.add(course);
      } catch (e) {}
    }
    return ret;
  }

  static Course parseXMLCourse(String courseString, courseId) {
    XmlDocument courseXML = XmlDocument.parse(courseString);
    List<XmlNode> deckNodes = courseXML.rootElement.children
        .where((xmlNode) => xmlNode.toString().startsWith('<deck '))
        .toList();

    List<Deck> decks;
    String? colorsAttribute = courseXML.rootElement.getAttribute("colors");
    if (colorsAttribute == null) {
      decks = parseQuizDecks(deckNodes, courseId);
    } else {
      decks = parseQuizDecks(
        deckNodes,
        courseId,
        courseColors: parseCourseColors(colorsAttribute),
      );
    }
    String titleAttribute =
        courseXML.rootElement.getAttribute("title") ?? courseId;

    String? languageAttribute = courseXML.rootElement.getAttribute("language");
    languageAttribute ??= "en";

    int decksUnlocked = CourseMetadataStorage.getDecksUnlocked(courseId);
    return Course(
        decks: decks,
        id: courseId,
        decksUnlocked: decksUnlocked,
        language: languageAttribute,
        title: titleAttribute);
  }

  /// Parses a QuizCourse file using the course ID and returns a QuizCourse object
  /// Is asyncronous due to disk operations
  static Future<Course> getCourse(String courseID) async {
    String courseString = await getCourseString(courseID);
    if (courseString.startsWith('<')) {
      return parseXMLCourse(courseString, courseID);
    }
    if (courseString.startsWith("{")) {
      return Course.fromJSON(jsonDecode(courseString));
    }
    throw Exception(
        "The course $courseID is not a correct JSON representation of a course");
  }

  /// Parses the colorscheme of a course given as its color attribute of the form
  /// c_1,c_2,c_3,c_4
  /// each c_i is a color given in hexadecimal notation. E.g. FFFFFF = white
  static List<Color> parseCourseColors(String colorsAttribute) {
    List<String> stringColors = colorsAttribute.split(',');
    return [for (String stringColor in stringColors) HexColor(stringColor)];
  }

  /// Parses all quiz-deck objects within a given quiz-course file and returns
  /// a list containing them
  static List<Deck> parseQuizDecks(
    List<XmlNode> deckNodes,
    String courseId, {
    List<Color> courseColors = const [],
  }) {
    // the list to be returned
    List<Deck> ret = [];
    for (XmlNode deckNode in deckNodes) {
      // TODO: Add try, catch
      String name = deckNode.getAttribute("name")!;

      // generate the knowledgePath for each deck
      String knowledgePath = deckNode.getAttribute("knowledgePath")!;

      // Parse how often the deck should be practice. If not available, put 10
      int minToPractice =
          int.parse(deckNode.getAttribute("minToPractice") ?? "10");

      // If the deck has a color attribute, this color is assigned to it
      // If not, the color scheme of the course is used (if available)
      // If the course doesnt have a color scheme, the deck will get the color
      // deepOrange
      Color deckColor = Colors.deepOrange;
      String? colorString = deckNode.getAttribute("color");
      if (colorString != null) {
        deckColor = HexColor(colorString);
      } else if (courseColors.isNotEmpty) {
        deckColor = ColorTransform.gradientColorMix(
            (ret.length.toDouble() / deckNodes.length.toDouble()),
            courseColors);
      }

      // For futureproofing, the deck has an optional attribute 'isNameMath'
      // It is set to true by default
      bool isNameMath = true;
      String? isNameMathString = deckNode.getAttribute("isNameMath");
      if (isNameMathString != null) {
        isNameMathString.toLowerCase();
        isNameMath = isNameMathString != "false";
      }

      // The piece of code parses all keywords of a deck. Those will be displayed
      // in the background of a deck-screen
      List<XmlNode> keywordNodes = deckNode.children
          .where((element) => element.toString().startsWith("<keyword>"))
          .toList();
      List<String> keywords = [for (XmlNode node in keywordNodes) node.text];

      // creates the QuizDeck-object from the parsed variables and adds it to the
      // list that is to be returned.
      Deck toAdd = Deck(
        id: knowledgePath,
        title: name,
        keywords: keywords,
        courseId: courseId,
        deckColor: deckColor,
        minToPractice: minToPractice,
        isNameMath: isNameMath,
      );
      toAdd.timesPracticed = DeckMetadataStorage.getTimesPracticed(toAdd.id);
      ret.add(toAdd);
    }
    return ret;
  }
}
