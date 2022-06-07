// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:focuslocus/widgets/quiz_card_items/correction.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';

/// A file containing Small frameworks to test widgets that are in development.
/// Additionally contains flags that can be set to test some functionality in
/// debug mode.
class TestConstants {
  /// If this flag is set, the variable 'hasSeenWelcomeScreen' will evaluate to
  /// false
  // ignore: dead_code
  static const bool testWelcomeScreen = true && kDebugMode;

  /// If this flag is set, the LRS Responses screen will be accessible through the
  /// app menu.
  // ignore: dead_code
  static const bool testLRSSync = false && kDebugMode;
}

class TestApp extends StatefulWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  bool revealed = false;
  bool errors = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wildcards',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.

        fontFamily: 'OpenDyslexic',
        textTheme: const TextTheme(
          bodyText2: TextStyle(
            fontSize: 30,
          ),
          button: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          headline6: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  FoloButton(
                    child: const Text("Flip reveal"),
                    onPressed: () {
                      setState(() {
                        revealed = !revealed;
                      });
                    },
                  ),
                  FoloButton(
                    child: const Text("Flip Error"),
                    onPressed: () {
                      setState(() {
                        errors = !errors;
                      });
                    },
                  ),
                ],
              ),
            ),
            Correction(
                quizCardID: "test",
                errors: errors ? 1 : 0,
                playtime: 0,
                revealed: revealed,
                onComplete: (
                    {commissionErrors = 0,
                    easy = true,
                    errors = 0,
                    omissionErrors = 0,
                    playtime = 0}) {}),
          ],
        ),
      ),
    );
  }
}
