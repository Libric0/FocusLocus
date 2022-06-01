import 'package:flutter/material.dart';
import 'package:focuslocus/knowledge/quiz_deck.dart';

/// The representation of a course within an application. It contains a list of
/// decks, has a unique identifier and tracks how many decks have been unlocked
class QuizCourse {
  /// The decks within this course
  List<QuizDeck> decks;

  /// The unique identifier of this course. It corresponds to the folder in
  /// which the course-files are stored. In the future it may only be a key
  /// for a key-value database that stores the course-files internally
  final String id;

  /// How many decks have been unlocked so far. For the pilot study, this
  /// functionality could not be used, because users were testing the application
  /// close to the exam.
  int decksUnlocked;

  /// The non-unique name for the course.
  late final String name;

  /// The abbreviation of the name of the course. If longer than 6 letters, it
  /// is cropped
  late final String abbreviation;

  /// The language this quiz is is. If no language is given, it is assumed to be
  /// english
  final String language;

  QuizCourse(
      {required this.decks,
      required this.id,
      required this.language,
      this.decksUnlocked = 0,
      String? name,
      String? abbreviation}) {
    // Making sure the course has a name, at worst its id
    if (name != null) {
      this.name = name;
    } else {
      this.name = id;
    }

    // Making sure the course has an abbreviation, at worst its id. Both cropped to 6 letters
    if (abbreviation != null) {
      if (abbreviation.length > 6) {
        this.abbreviation = abbreviation.substring(0, 6);
      } else {
        this.abbreviation = abbreviation;
      }
    } else {
      if (id.length > 6) {
        this.abbreviation = id.substring(0, 6);
      } else {
        this.abbreviation = id;
      }
    }
  }
}
