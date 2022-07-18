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
import 'package:focuslocus/knowledge/knowledge_multiple_choice.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/quiz_card_items/quiz_card_help_dialog.dart';
import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/correction_wrapper.dart';
import 'package:focuslocus/widgets/quiz_card_items/question_card.dart';
import 'package:focuslocus/widgets/quiz_card_items/selectable_button.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/playtime_clock_wrapper.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/quiz_card_screen_pause_observer_wrapper.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The simplest kind of 'select fact' quizcard. The player is presented with
/// a bunch of buttons and has to choose which of them are facts.
class MultipleChoiceButtonScreen extends QuizCardScreen {
  final List<KnowledgeMultipleChoiceTexText> multipleChoice;
  const MultipleChoiceButtonScreen({
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
          key: key,
          onComplete: onComplete,
          knowledge: multipleChoice,
          color: color,
          cardType: "multiple_choice_button",
        );

  @override
  _MultipleChoiceButtonScreenState createState() =>
      _MultipleChoiceButtonScreenState();

  /// The help dialog for this screen
  @override
  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => QuizCardHelpDialog(
        color: color,
        children: [
          FoloCard(
            color: color,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  AppLocalizations.of(context)!
                      .multipleChoiceButtonSelectAllCorrectStatements,
                  textAlign: TextAlign.center,
                  style: (Theme.of(context).textTheme.headline6 ??
                          const TextStyle())
                      .copyWith(color: ColorTransform.textColor(color))),
            ),
          ),
          FoloCard(
            color: color,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SelectableButton(
                    texTextString: AppLocalizations.of(context)!.statement,
                    hasCorrectStatement: true,
                    revealed: false,
                    selected: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(AppLocalizations.of(context)!
                      .multipleChoiceButtonSelectSelectedStatementsAreHighlightedInBlue),
                ],
              ),
            ),
          ),
          FoloCard(
            color: color,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!
                      .multipleChoiceButtonSelectAsYouTapOnDone),
                  const SizedBox(
                    height: 20,
                  ),
                  SelectableButton(
                      selected: true,
                      texTextString: AppLocalizations.of(context)!.trueWord,
                      hasCorrectStatement: true,
                      revealed: true),
                  const SizedBox(
                    height: 10,
                  ),
                  SelectableButton(
                      texTextString: AppLocalizations.of(context)!.falseWord,
                      hasCorrectStatement: false,
                      revealed: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chooses the knowledge items and then displays a Revealable Truthbutton Column
class _MultipleChoiceButtonScreenState
    extends State<MultipleChoiceButtonScreen> {
  @override
  void initState() {
    super.initState();
  }

  List<String> chosenItems = [];
  bool firstBuild = true;
  int playtime = 0;
  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      //LearningMetadataStorage.increment(
      //    widget.cardType, QuizCardMetadataType.numberStarted);
      chosenItems = chooseKnowledgeItems(widget.multipleChoice[0]);
      firstBuild = false;
    }
    return QuizCardScreenPauseObserverWrapper(
      cardType: widget.cardType,
      child: PlaytimeClockWrapper(
        routine: () {
          playtime++;
        },
        child: Column(
          children: [
            QuestionCard(
              question: widget.knowledge.length == 1
                  ? widget.multipleChoice[0].questions[0]
                  : AppLocalizations.of(context)!
                      .multipleChoiceButtonSelectWhichStatementsAreCorrect,
              color: widget.color,
            ),
            Expanded(
              child: RevealableTruthButtonColumn(
                  multipleChoiceTexText: widget.multipleChoice[0],
                  chosenItems: chosenItems,
                  onComplete: widget.onComplete,
                  color: widget.color),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }

  /// Chooses at most 5 statements from a QuizMultipleChoiceTexText item.
  List<String> chooseKnowledgeItems(
      KnowledgeMultipleChoiceTexText multipleChoiceTexText) {
    Random random = Random(DateTime.now().hashCode);
    List<String> ret = [];
    ret
      ..addAll(multipleChoiceTexText.correctChoices)
      ..addAll(multipleChoiceTexText.incorrectChoices)
      ..shuffle(random);
    if (ret.length > 5) {
      ret = ret.sublist(0, 5);
    }
    return ret;
  }
}

class RevealableTruthButtonColumn extends StatefulWidget {
  final KnowledgeMultipleChoiceTexText multipleChoiceTexText;
  final void Function({
    int errors,
    int commissionErrors,
    int omissionErrors,
    required int playtime,
    bool easy,
  }) onComplete;
  // The items that were chosen to be displayed
  final List<String> chosenItems;
  // The color of the column
  final Color color;
  const RevealableTruthButtonColumn(
      {required this.multipleChoiceTexText,
      required this.onComplete,
      required this.chosenItems,
      this.color = Colors.blue,
      Key? key})
      : super(key: key);

  @override
  _RevealableTruthButtonColumnState createState() =>
      _RevealableTruthButtonColumnState();
}

class _RevealableTruthButtonColumnState
    extends State<RevealableTruthButtonColumn> {
  bool firstBuild = true;

  /// Whether the answer has been revealed yet
  bool revealed = false;
  int playtime = 0;
  int errors = 0;
  int commissionErrors = 0;
  int omissionErrors = 0;
  Timer _timer = Timer.periodic(const Duration(seconds: 1), (timer) {});
  // For each button it's selection state has been selected
  List<bool> selected = [for (int i = 0; i < 5; i++) false];
  ScrollController listViewController = ScrollController();

  // whether the scrolling indicator should be displaysd
  bool showArrowDown = false;
  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      // the list scrolls up as far as possible the first time it is rendered
      Future.microtask(() {
        listViewController.jumpTo(listViewController.position.maxScrollExtent);
        if (listViewController.position.minScrollExtent !=
            listViewController.position.maxScrollExtent) {
          setState(() {
            showArrowDown = true;
          });
        }
      });

      // The timer is used to animate whether the list has an indicator, in case
      // it has to be scrolled
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        playtime++;

        if (listViewController.position.extentBefore == 0) {
          setState(() {
            showArrowDown = false;
          });
        } else {
          setState(() {
            showArrowDown = true;
          });
        }
      });

      firstBuild = false;
    }
    return CorrectionWrapper(
      quizCardID: widget.multipleChoiceTexText.id,
      revealed: revealed,
      onComplete: widget.onComplete,
      playtime: playtime,
      commissionErrors: commissionErrors,
      omissionErrors: omissionErrors,
      errors: errors,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 5),
                        blurRadius: 10,
                        color: ColorTransform.withValue(widget.color, .6)
                            .withAlpha(100),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(25))),
                // the stack is used only to show the scrolling-indicator
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: ListView(
                        controller: listViewController,
                        reverse: true,
                        children: [
                          for (int i = 0; i < widget.chosenItems.length; i++)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                              child: SelectableButton(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      TexText(rawString: widget.chosenItems[i]),
                                ),
                                hasCorrectStatement: widget
                                    .multipleChoiceTexText.correctChoices
                                    .contains(widget.chosenItems[i]),
                                revealed: revealed,
                                selected: selected[i],
                                onChanged: () {
                                  setState(() {
                                    selected[i] = !selected[i];
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      // The scrolling indicator is animated into existence, once
                      // it is needed
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: showArrowDown ? 1 : 0,
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5))),
                          child: const Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The submit button
          Container(
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              color: Color.fromARGB(0, 0, 0, 0),
            ),
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
            child: Column(
              children: [
                Expanded(child: Container()),
                FoloButton(
                  height: 60,
                  color: widget.color,
                  shouldStretch: true,
                  child: Text(AppLocalizations.of(context)!.done),
                  onPressed: () {
                    setState(() {
                      revealed = true;
                      playtime = playtime;
                      calculateErrors();
                      _timer.cancel();
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void calculateErrors() {
    for (int i = 0; i < widget.chosenItems.length; i++) {
      // This evaluates to true iff (an item is selected iff an item belongs to
      // the correct statements)
      if (selected[i] !=
          widget.multipleChoiceTexText.correctChoices
              .contains(widget.chosenItems[i])) {
        errors++;
        if (selected[i]) {
          commissionErrors++;
        } else {
          omissionErrors++;
        }
      }
    }
  }
}
