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
import 'package:focuslocus/file_io/course_io.dart';
import 'package:focuslocus/knowledge/quiz_course.dart';
import 'package:focuslocus/local_storage/course_metadata_storage.dart';
import 'package:focuslocus/local_storage/user_storage.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/screens/course_overview.dart';
import 'package:focuslocus/widgets/screens/stats_screen.dart';
import 'package:focuslocus/widgets/screens/user_screen.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../test_utility.dart';
import 'help_screen.dart';
import 'lrs_responses_screen.dart';

/// The course selection screen. Displayed as a grid of buttons. Upon pressing such
/// a button, the course overview of the selected course is displayed.
class CourseSelection extends StatefulWidget {
  const CourseSelection({Key? key}) : super(key: key);

  @override
  State<CourseSelection> createState() => _CourseSelectionState();
}

class _CourseSelectionState extends State<CourseSelection> {
  bool firstBuild = true;
  @override
  Widget build(BuildContext context) {
    if (UserStorage.lastCourse != null && firstBuild) {
      Future.microtask(
        () => Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) =>
                getCourseOverview(UserStorage.lastCourse!, context),
          ),
        )
            .then(
          (value) {
            setState(
              () {},
            );
          },
        ),
      );
      firstBuild = false;
    }
    return getCourseGridView();
  }

  /// Returns the CourseGridView
  Widget getCourseGridView() {
    return FutureBuilder(
      future:
          Future.delayed(const Duration(seconds: 1), CourseIO.getAllCourses),
      builder: (context, AsyncSnapshot<List<QuizCourse>> snapshot) {
        if (snapshot.hasData) {
          return Container(
            color: ColorTransform.scaffoldBackgroundColor(Colors.teal),
            child: Column(
              children: [
                FoloCard(
                  child: Text(
                    AppLocalizations.of(context)!.chooseACourse,
                    style: (Theme.of(context).textTheme.headline5 ??
                            const TextStyle())
                        .copyWith(color: ColorTransform.textColor(Colors.teal)),
                  ),
                  color: Colors.teal,
                ),
                Expanded(
                  child: FoloCard(
                    color: Colors.teal,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.count(
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          crossAxisCount: 3,
                          children: [
                            for (QuizCourse course in snapshot.data!)
                              FoloButton(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FittedBox(
                                    child: Text(course.abbreviation),
                                  ),
                                ),
                                onPressed: () {
                                  UserStorage.lastCourse = course.id;
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          getCourseOverview(course.id, context),
                                    ),
                                  )
                                      .then(
                                    (value) {
                                      setState(
                                        () {},
                                      );
                                    },
                                  );
                                },
                                color: course
                                    .decks[
                                        CourseMetadataStorage.currentDeckIndex(
                                            course.id)]
                                    .deckColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Text(AppLocalizations.of(context)!
                  .coursesCouldNotBeLoadedPleaseRestart));
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget getCourseOverview(String courseName, BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: CourseIO.getCourse(courseName),
        builder: (context, AsyncSnapshot<QuizCourse> snapshot) {
          if (snapshot.hasData) {
            return Localizations.override(
              context: context,
              locale: Locale(snapshot.data!.language, ''),
              child: Builder(builder: (context) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  drawer: Drawer(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.batch_prediction),
                          title: Text(AppLocalizations.of(context)!.courses),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(AppLocalizations.of(context)!.user),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                            leading: const Icon(Icons.show_chart_rounded),
                            title: Text(AppLocalizations.of(context)!.stats),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StatsScreen(),
                                  ));
                            }),
                        ListTile(
                          leading: const Icon(Icons.help),
                          title: Text(AppLocalizations.of(context)!.help),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HelpScreen()));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: Text(AppLocalizations.of(context)!.about),
                          onTap: () {
                            showAboutDialog(
                                context: context,
                                applicationIcon: SizedBox(
                                  child: Image.asset("assets/icon/icon2.png",
                                      isAntiAlias: true),
                                  width: 100,
                                  height: 100,
                                ));
                          },
                        ),
                        if (TestConstants.testLRSSync)
                          ListTile(
                            leading: const Icon(Icons.storage),
                            title: Text(
                                AppLocalizations.of(context)!.lrsResponses),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LrsResponsesScreen()));
                            },
                          )
                      ],
                    ),
                  ),
                  body: CourseOverview(
                    course: snapshot.data!,
                    selectedDeck: CourseMetadataStorage.currentDeckIndex(
                            snapshot.data!.id)
                        .toDouble(),
                  ),
                );
              }),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!
                    .courseCouldNotBeLoaded(courseName),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
