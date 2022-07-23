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
import 'package:focuslocus/knowledge/quiz_deck.dart';
import 'package:focuslocus/knowledge/knowledge_item.dart';
import 'package:focuslocus/local_storage/knowledge_metadata_storage.dart';
import 'package:focuslocus/local_storage/learning_metadata_storage.dart';
import 'package:focuslocus/local_storage/quiz_card_metadata_type.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_finished_screen.dart';
import 'package:focuslocus/widgets/ui_elements/folo_progress_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This screen is responsible for showing QuizCardScreens and managing the progress
/// bar. It also provides a ?-button to get information about the currently displayed
/// quiz-card.
///
/// During a quiz, it counts the errors and saves them to the QuizCardMetadataStorage
///
/// After a quiz is finished it shows the QuizFinishedScreen
class QuizScreen extends StatelessWidget {
  /// The method that is called
  final Function onFinish;
  final List<QuizDeck> decks;
  final Color color;
  final int numberScreens;
  const QuizScreen(
      {Key? key,
      required this.decks,
      this.color = Colors.blue,
      required this.onFinish,
      this.numberScreens = 10})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<List<KnowledgeItem>>? quizKnowledgeItemsFuture =
        decks[0].scheduleKnowledgeItems(numberScreens);
    return FutureBuilder(
      future: quizKnowledgeItemsFuture,
      builder: (context, AsyncSnapshot<List<KnowledgeItem>> snapshot) {
        if (snapshot.hasData) {
          return _BuiltQuizScreen(
            color: color,
            quizKnowlegeItems: snapshot.data!,
            decks: decks,
            onFinish: onFinish,
            numberScreens: numberScreens,
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Container(),
          );
        } else {
          return Scaffold(
              backgroundColor: ColorTransform.scaffoldBackgroundColor(color),
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: color,
                        strokeWidth: 5,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        AppLocalizations.of(context)!.quizScreenLoadingCards,
                        style: TextStyle(color: color),
                      ),
                    ],
                  ),
                ),
              ));
        }
      },
    );
  }
}

class _BuiltQuizScreen extends StatefulWidget {
  final Color color;
  final List<QuizDeck> decks;
  final List<KnowledgeItem> quizKnowlegeItems;
  final Function onFinish;
  final int numberScreens;
  const _BuiltQuizScreen(
      {this.color = Colors.deepOrange,
      required this.quizKnowlegeItems,
      required this.decks,
      required this.onFinish,
      required this.numberScreens,
      Key? key})
      : super(key: key);

  @override
  _BuiltQuizScreenState createState() => _BuiltQuizScreenState();
}

class _BuiltQuizScreenState extends State<_BuiltQuizScreen> {
  /// The index of the currentScreen
  int correct = 0;
  int incorrect = 0;
  bool finished = false;

  ///The number of screens
  int numberScreens = 0;
  int currentScreen = 0;
  bool firstBuild = true;
  PageController exercisePageController = PageController();
  PageController quizScreenPageController = PageController();
  List<QuizCardScreen> scheduledCardScreens = [];
  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      scheduledCardScreens = [
        for (KnowledgeItem knowledgeItem in widget.quizKnowlegeItems)
          knowledgeItem.getRandomScreen(widget.color, exerciseDone, context)
      ];

      numberScreens = scheduledCardScreens.length;
      scheduleCard(scheduledCardScreens[0]);
      firstBuild = false;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorTransform.scaffoldBackgroundColor(widget.color),
      body: SafeArea(
        child: Column(
          children: [
            if (!finished)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                        //width: 48,
                        ),
                    TweenAnimationBuilder(
                        tween: Tween<double>(
                            begin: 0,
                            // The numberscreens is one more than should be shown,
                            // because we always have the currentScreen at the end
                            // due to a discrepancy with flutter: If one makes a mistake
                            // only on the last screen, the pageView can only scroll
                            // to the rescheduled version of it, if it already existed
                            // before the errornous solution was corrected. Therefore
                            // the current Screen is always added to end of the list
                            // before playing it and removed after the correct solution
                            // was inserted. Thus, the number of screens is always
                            // one higher than should be shown.
                            end: (currentScreen.toDouble()) /
                                (numberScreens.toDouble() - 1)),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.bounceInOut,
                        builder: (context, double value, _) {
                          return Flexible(
                            //maxWidth: MediaQuery.of(context).size.width - 64,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 4.0),
                              child: FoloProgressIndicator(
                                color: widget.color,
                                value: value,
                                backgroundColor:
                                    ColorTransform.widgetBackgroundColor(
                                        widget.color),
                              ),
                            ),
                          );
                        }),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                          onPressed: () {
                            scheduledCardScreens[currentScreen]
                                .showHelpDialog(context);
                          },
                          icon: Icon(
                            Icons.help_outline,
                            color: widget.color,
                            size: 40,
                          )),
                    )
                  ],
                ),
              ),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: quizScreenPageController,
                children: [
                  PageView(
                    controller: exercisePageController,
                    children: scheduledCardScreens,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  QuizFinishedScreen(
                    onFinish: () {
                      if (widget.decks.length == 1) {
                        widget.decks[0].timesPracticed++;
                      }
                      widget.onFinish();
                    },
                    color: widget.color,
                    correct: correct,
                    incorrect: incorrect,
                  )
                ],
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }

  void exerciseDone({
    // Errors is supposed to be either the sum of commissionErrors and
    // omissionErrors, or the other two are 0.
    int errors = 0,
    int commissionErrors = 0,
    int omissionErrors = 0,
    required int playtime,
    bool easy = false,
  }) {
    saveQuizCardMetadata(
        playtime: playtime,
        errors: errors,
        commissionErrors: commissionErrors,
        omissionErrors: omissionErrors,
        easy: easy);

    // print("Errors: $errors - CE: $commissionErrors - OE: $omissionErrors - Playtime: $playtime");
    setState(() {
      // The knowledge ID for the quizcardmetadata storage
      String knowledgeID = scheduledCardScreens[currentScreen].knowledge[0].id;

      rescheduleCard(scheduledCardScreens[currentScreen], errors, knowledgeID);
      currentScreen++;
      if (currentScreen < numberScreens) {
        // This happens when the current screen is not the last screen
        // The exercisePageview switches to the next assignment

        scheduleCard(scheduledCardScreens[currentScreen]);
        exercisePageController.nextPage(
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      } else {
        // This happens when the current screen. The quizScreenPageview switches
        // to the 'Quiz Finished Screen'
        finished = true;
        quizScreenPageController.nextPage(
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        );
        currentScreen++;
      }
    });
  }

  /// Does everything necessary for rescheduling a QuizCardScreen when the wrong
  /// answer is given. In the current iteration it actually works the other way
  /// around: It removes the last item of the "scheduledCardScreens"- List if
  /// there were no errors.
  void rescheduleCard(
      QuizCardScreen quizCardScreen, errors, String knowledgeID) {
    int lastInterval = KnowledgeMetadataStorage.getLastInterval(knowledgeID);
    if (errors == 0) {
      // The last screen is the one that was added by scheduleCard
      scheduledCardScreens.removeLast();
      // Since we dont have to play the just removed screen, we remove screensleft
      numberScreens--;

      // Now the rescheduling in persistent Storage
      // Incrementing learning metadata
      LearningMetadataStorage.increment(
          scheduledCardScreens[currentScreen].cardType,
          QuizCardMetadataType.numberSucceeded);

      // Rescheduling

      // Setting the next Interval to 1 if it was 0, and to 2*lastinterval,
      // capped by 16
      int nextInterval =
          lastInterval < 16 ? max(1, 2 * lastInterval) : lastInterval;
      KnowledgeMetadataStorage.setLastInterval(knowledgeID, nextInterval);
      KnowledgeMetadataStorage.setDue(
          knowledgeID, DateTime.now().add(Duration(days: nextInterval)));

      // If the number of screens has not been exceeded (i.e. all screens are
      // shown for their respective first times), we increase the number of
      // correct screens
      if (currentScreen < widget.numberScreens) {
        correct++;
      }
    } else {
      // setting rescheduling it today with lastInterval = 1
      KnowledgeMetadataStorage.setLastInterval(knowledgeID, 1);
      KnowledgeMetadataStorage.setDue(knowledgeID, DateTime.now());
      if (currentScreen < widget.numberScreens) {
        incorrect++;
      }
    }
    KnowledgeMetadataStorage.setLastPracticed(knowledgeID, DateTime.now());
  }

  /// Does everything necessary to schedule a QuizCardScreen
  /// In the current iteration, it adds the quizcardScreen to the end of the list
  /// and increases the number of items left. The rescheduler then removes it, if
  /// no errors occured
  void scheduleCard(QuizCardScreen quizCardScreen) {
    scheduledCardScreens.add(quizCardScreen);
    numberScreens++;
  }

  /// Updates the knowledgemetadata of the (just played) current screen with it's
  /// results
  void saveQuizCardMetadata({
    int errors = 0,
    int commissionErrors = 0,
    int omissionErrors = 0,
    required int playtime,
    bool easy = false,
  }) {
    // First, the right metadata is stored inside the Hive
    // Increasing the number of played cards of that type
    LearningMetadataStorage.increment(
        scheduledCardScreens[currentScreen].cardType,
        QuizCardMetadataType.numberCompleted);

    // Now add the playtime in seconds
    LearningMetadataStorage.add(scheduledCardScreens[currentScreen].cardType,
        QuizCardMetadataType.sumPlaytime, playtime);

    // Now add all types of Errors
    LearningMetadataStorage.add(scheduledCardScreens[currentScreen].cardType,
        QuizCardMetadataType.numberErrors, errors);
    // Errors of Comission
    LearningMetadataStorage.add(scheduledCardScreens[currentScreen].cardType,
        QuizCardMetadataType.numberCommissionErrors, commissionErrors);
    // Errors of Omission
    LearningMetadataStorage.add(scheduledCardScreens[currentScreen].cardType,
        QuizCardMetadataType.numberOmissionErrors, omissionErrors);
  }
}
