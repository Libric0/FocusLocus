// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:focuslocus/local_storage/adhd_type.dart';

/// Stores important information about the user and the state of their interaction
/// with the app persistently. It contains, for example, the pseudonym of the
/// user and whether they saw the welcome screen or not.
class UserStorage {
  static Box? _actorStorageBox;

  /// Initializes the box and, if not pseudonym exists yet (on first start),
  /// it generates a random pseudonym
  static Future<void> init() async {
    _actorStorageBox ??= await Hive.openBox("userStorage");
    if (!_actorStorageBox!.keys.contains("pseudonym")) {
      Random random = Random.secure();
      // creation of the pseudonym
      List<int> pseudonymAscii = [];

      for (int i = 0; i < 128; i++) {
        if (random.nextBool()) {
          pseudonymAscii.add(123 - 26 + random.nextInt(26));
        } else {
          pseudonymAscii.add(123 - 26 + random.nextInt(26) - 6 - 26);
        }
      }

      // converts it to an askii string, hive requires that for keys
      var decoder = const AsciiDecoder();
      String pseudonym = decoder.convert(pseudonymAscii);

      _actorStorageBox!.put("pseudonym", pseudonym);
    }
  }

  /// returns whether the user has seen the welcome screen or not
  // static bool get hasSeenWelcomeScreen =>
  //     _actorStorageBox!.get("hasSeenWelcomeScreen") ?? false;
  // TODO: reinstate welcome screen
  static bool get hasSeenWelcomeScreen => true;

  /// When the user exits the welcome screen, this is set to true, so that
  /// the welcome screen is not shown twice
  static set hasSeenWelcomeScreen(bool value) {
    _actorStorageBox!.put("hasSeenWelcomeScreen", value);
  }

  /// Is used by the LRSsync to determine whether it can send data to the LRS
  /// or not
  //TODO: Reinstate actual consent,static bool get hasConsent =>
  //    (_actorStorageBox!.get("hasConsent") ?? false) && hasSeenWelcomeScreen;
  static bool get hasConsent => false;

  /// Is set to true when the user consents
  static set hasConsent(bool value) {
    _actorStorageBox!.put("hasConsent", value);
  }

  /// If the user does not consent, they will not upload their adhd type either.
  /// If they retroactively decide to send data, this is checked. If it is false,
  /// the user is asked again for their ADHD type.
  static bool get hasUploadedADHDType =>
      _actorStorageBox!.get("hasUploadedADHDType") ?? false;

  /// When the user uploads the ADHD type, this value is set to true.
  static set hasUploadedADHDType(bool value) =>
      _actorStorageBox!.put("hasUploadedADHDType", value);

  /// The ADHDType the user has.
  static ADHDType? get adhdType => _actorStorageBox!.get("adhdType");

  /// When the user selects their ADHDType, the selected value is stored here.
  static set adhdType(ADHDType? type) {
    _actorStorageBox!.put("adhdType", type);
  }

  /// The value is checked everytime the app is opened. If the date is yesterday
  /// or earlier, the learning data is sent to the LRS (with consent only)
  static DateTime get lastSynced =>
      _actorStorageBox!.get("lastSynced") ??
      DateTime.now().subtract(const Duration(days: 2));

  /// After the learning data was sent to the LRS, the current date is saved as
  /// lastSynced
  static void markSynced() {
    DateTime now = DateTime.now();
    DateTime nowRounded = now.subtract(Duration(
        hours: now.hour,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
        microseconds: now.microsecond));
    _actorStorageBox!.put("lastSynced", nowRounded);
  }

  /// The pseudonym that is generated randomly the first time the application is
  /// opened.
  static String get pseudonym => _actorStorageBox!.get("pseudonym");

  /// Gives access to the courseID of the last course the user visited
  static String? get lastCourse => _actorStorageBox!.get("lastCourse");

  /// Changes the last course the user visited to the provided courseID
  static set lastCourse(String? courseID) {
    _actorStorageBox!.put("lastCourse", courseID);
  }
}
