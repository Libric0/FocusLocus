import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:focuslocus/local_storage/user_storage.dart';
import 'package:focuslocus/test_utility.dart';
import 'package:focuslocus/widgets/screens/welcome_screen.dart';

import 'screens/course_selection.dart';

/// Main App widget including the introduction screen, if not shown already
/// or instantly skipping to the course

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool welcomeScreenVisible = true;

  @override
  Widget build(BuildContext context) {
    if (TestConstants.testWelcomeScreen) {
      UserStorage.hasSeenWelcomeScreen = false;
    }
    return Stack(children: [
      TweenAnimationBuilder(
          duration: const Duration(milliseconds: 200),
          tween: Tween<double>(
              begin: 0,
              end: !UserStorage.hasSeenWelcomeScreen && welcomeScreenVisible
                  ? 1.0
                  : 0.0),
          builder: (context, double value, _) {
            return Stack(
              children: [
                ImageFiltered(
                  imageFilter:
                      ImageFilter.blur(sigmaX: value * 3, sigmaY: value * 3),
                  child: const CourseSelection(),
                ),
                Transform.translate(
                  offset: Offset(0, (1 - value) * 500),
                  child: Visibility(
                    visible: value != 0,
                    child: Opacity(
                      opacity: value,
                      child: WelcomeScreen(
                        closeCallBack: () {
                          setState(() {
                            welcomeScreenVisible = false;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    ]);
  }
}
