// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:focuslocus/knowledge/multiple_choice.dart';
import 'package:focuslocus/util/perception_adjusted_colors.dart';
import 'package:tcard/tcard.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/quiz_card_items/question_card.dart';
import 'package:focuslocus/widgets/quiz_card_items/correction.dart';
import 'package:focuslocus/widgets/quiz_card_items/quiz_card_help_dialog.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/quiz_card_screen_pause_observer_wrapper.dart';
import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../quiz_card_screen.dart';

/// This QuizScreen is another implementation of a Multiple-Choice quiz. In it,
/// one card is revealed at once sequentially. Swiping right translates to "the
/// content of this card is correct", swiping left marks the content as incorrect.
/// Afterwards, a feedback screen is shown to the user, containing corrections
/// for all wrong choices
///
/// It can be interesting in many ways. RQs that may be tested here are
/// - Is a deviation from the standard, and maybe a resemblence to another
/// app (tinder) useful for keeping focus?
/// - The feedback within those cards is less immediate. Does that make a
/// difference for motivation (E.g. ask participants how much they like the card)
class MultipleChoiceSwipingScreen extends QuizCardScreen {
  final List<MultipleChoice> multipleChoice;
  const MultipleChoiceSwipingScreen({
    required void Function({
      int errors,
      int commissionErrors,
      int omissionErrors,
      required int playtime,
      bool easy,
    })
        onComplete,
    required this.multipleChoice,
    required Color color,
    Key? key,
  }) : super(
          color: color,
          cardType: "multiple_choice_swiping",
          knowledge: multipleChoice,
          onComplete: onComplete,
          key: key,
        );

  @override
  _MultipleChoiceSwipingScreenState createState() =>
      _MultipleChoiceSwipingScreenState();

  @override
  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => QuizCardHelpDialog(
        color: color,
        children: [
          FoloCard(
            color: color,
            child: Text(
              AppLocalizations.of(context)!
                  .multipleChoiceSwipingSwipingSwipeCorrectCardsRightAndIncorrectOnesLeft,
              style:
                  (Theme.of(context).textTheme.bodyText1 ?? const TextStyle())
                      .copyWith(color: ColorTransform.textColor(color)),
              textAlign: TextAlign.center,
            ),
          ),
          FoloCard(
            color: color,
            child: SizedBox(
              height: 450,
              child: Image.asset(
                  //TODO: Localize images or make them procedural
                  "assets/help_dialogs/multiple_choice_swiping_screen_wahr.png"),
            ),
          ),
          FoloCard(
            color: color,
            child: SizedBox(
              height: 450,
              child: Image.asset(
                  "assets/help_dialogs/multiple_choice_swiping_screen_falsch.png"),
            ),
          ),
        ],
      ),
    );
  }
}

class _MultipleChoiceSwipingScreenState
    extends State<MultipleChoiceSwipingScreen> {
  bool onEndScreen = false;
  int playtime = 0;
  Timer _timer = Timer.periodic(const Duration(seconds: 1), (timer) {});
  bool firstBuild = true;
  List<String> chosenItems = [];
  List<String> commissionErrors = [];
  List<String> omissionErrors = [];
  TCardController tCardController = TCardController();
  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        playtime++;
      });
      //LearningMetadataStorage.increment(
      //  widget.cardType, QuizCardMetadataType.numberStarted);
      chosenItems = chooseKnowledgeItems(widget.multipleChoice[0]);
      firstBuild = false;
    }
    return QuizCardScreenPauseObserverWrapper(
      cardType: widget.cardType,
      child: Stack(
        children: [
          // The red and green indicators on the side
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                decoration: BoxDecoration(
                    color: PerceptionAdjustedColors.bad,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    )),
                width: 8,
              ),
              Expanded(
                flex: 50,
                child: Container(),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                decoration: BoxDecoration(
                    color: PerceptionAdjustedColors.good,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    )),
                width: 8,
              ),
            ],
          ),
          // The actual question and below the stack of answers
          Column(
            children: [
              QuestionCard(
                question: widget.multipleChoice[0].questions[0],
                color: widget.color,
              ),
              Expanded(
                // The tinder-card swiping widget
                child: TCard(
                  slideSpeed: 30,
                  size: const Size(double.infinity, double.infinity),
                  onForward: (index, info) {
                    bool answeredYes = SwipDirection.Right == info.direction;
                    if (answeredYes ==
                        widget.multipleChoice[0].correct
                            .contains(chosenItems[index - 1])) {
                    } else {
                      if (answeredYes) {
                        commissionErrors.add(chosenItems[index - 1]);
                      } else {
                        omissionErrors.add(chosenItems[index - 1]);
                      }
                    }
                  },
                  onEnd: () {
                    setState(() {
                      playtime = playtime;
                      onEndScreen = true;
                    });
                  },
                  cards: [
                    for (String s in chosenItems)
                      // ignore: avoid_unnecessary_containers
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(0, 5),
                              blurRadius: 10,
                              color: Color.fromARGB(100, 0, 0, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: TexText(
                            rawString: s,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Only if the widget is currently on the end screen, it displays
          // a statistic of what was right and what was wrong
          if (onEndScreen)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: 0,
                  child: QuestionCard(
                    question: widget.multipleChoice[0].questions[0],
                    color: widget.color,
                  ),
                ),
                if (commissionErrors.isNotEmpty || omissionErrors.isNotEmpty)
                  Expanded(
                    child: FoloCard(
                      color: widget.color,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: ListView(
                          children: [
                            if (omissionErrors.isNotEmpty)
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                decoration: BoxDecoration(
                                    color: PerceptionAdjustedColors.good,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                width: double.maxFinite,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .multipleChoiceSwipingCorrectWouldHaveBeen,
                                  style:
                                      (Theme.of(context).textTheme.headline5 ??
                                              const TextStyle())
                                          .copyWith(color: Colors.white),
                                ),
                              ),
                            if (omissionErrors.isNotEmpty)
                              getErrorList(omissionErrors),
                            if (omissionErrors.isNotEmpty)
                              const SizedBox(
                                height: 20,
                              ),
                            if (commissionErrors.isNotEmpty)
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                decoration: BoxDecoration(
                                    color: PerceptionAdjustedColors.bad,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                width: double.maxFinite,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .multipleChoiceSwipingIncorrectWouldHaveBeen,
                                  style:
                                      (Theme.of(context).textTheme.headline5 ??
                                              const TextStyle())
                                          .copyWith(color: Colors.white),
                                ),
                              ),
                            getErrorList(commissionErrors)
                          ],
                        ),
                      ),
                    ),
                  ),
                Correction(
                  quizCardID: widget.knowledge[0].id,
                  onComplete: widget.onComplete,
                  playtime: playtime,
                  errors: commissionErrors.length + omissionErrors.length,
                  revealed: onEndScreen,
                  commissionErrors: commissionErrors.length,
                  omissionErrors: omissionErrors.length,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Column getErrorList(List<String> errors) {
    List<Widget> ret = [];
    for (String error in errors) {
      ret.add(
        TexText(
          rawString: error,
          style: TextStyle(
            color: ColorTransform.textColor(widget.color),
          ),
        ),
      );
      if (error != errors.last) {
        ret.add(const Divider());
      }
    }
    return Column(children: ret);
  }

  /// Chooses at most 5 statements from a QuizMultipleChoiceTexText item.
  List<String> chooseKnowledgeItems(MultipleChoice multipleChoice) {
    Random random = Random(DateTime.now().hashCode);
    List<String> strings = [];
    strings
      ..addAll(multipleChoice.correct)
      ..addAll(multipleChoice.incorrect)
      ..shuffle(random);
    if (strings.length > 5) {
      strings = strings.sublist(0, 5);
    }
    return strings;
  }
}
