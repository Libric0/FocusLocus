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

import 'package:focuslocus/knowledge/knowledge_statement.dart';
import 'package:flutter/material.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/quiz_card_items/question_card.dart';
import 'package:focuslocus/widgets/quiz_card_items/quiz_card_help_dialog.dart';
import 'package:focuslocus/widgets/quiz_card_items/selectable_button.dart';
import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/correction_wrapper.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/playtime_clock_wrapper.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/quiz_card_screen_pause_observer_wrapper.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../quiz_card_screen.dart';

/// The quiz-card-type in which the user has to select a word from a list
/// of choices to fill a gap within a statement
class StatementCompleteSelectionScreen extends QuizCardScreen {
  final List<KnowledgeStatement> statements;

  const StatementCompleteSelectionScreen({
    required this.statements,
    required Function(
            {int commissionErrors,
            bool easy,
            int errors,
            int omissionErrors,
            required int playtime})
        onComplete,
    required Color color,
    Key? key,
  }) : super(
          cardType: "statement_complete_selection",
          knowledge: statements,
          onComplete: onComplete,
          color: color,
          key: key,
        );

  @override
  _StatementCompleteSelectionScreenState createState() =>
      _StatementCompleteSelectionScreenState();

  @override
  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => QuizCardHelpDialog(children: [
        FoloCard(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              AppLocalizations.of(context)!
                  .statementCompleteSelectionChooseTheRightWordToFillTheGap,
              style:
                  (Theme.of(context).textTheme.headline6 ?? const TextStyle())
                      .copyWith(color: ColorTransform.textColor(color)),
            ),
          ),
        ),
        FoloCard(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!
                    .statementCompleteSelectionTheTextHasAGap),
                Image.asset(
                    //TODO: Localize screenshots or make procedural examples
                    "assets/help_dialogs/statement_complete_selection_screen_unselected.png")
              ],
            ),
          ),
        ),
        FoloCard(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!
                    .statementCompleteSelecionTheSelectedWordWillBeHighlightedInBlueAndInsertedIntoTheGap),
                Image.asset(
                    //TODO: Localize screenshots or make procedural examples
                    "assets/help_dialogs/statement_complete_selection_screen_selected.png")
              ],
            ),
          ),
        ),
      ], color: color),
    );
  }
}

class _StatementCompleteSelectionScreenState
    extends State<StatementCompleteSelectionScreen> {
  String correctFillIn = "";
  String beforeSelectable = "", selectable = " ", afterSelectable = "";
  bool firstBuild = true;
  int playtime = 0;
  int errors = 0;
  bool revealed = false;
  List<String> buttonText = [];
  List<bool> buttonSelected = [for (int i = 0; i < 5; i++) false];
  List<double> buttonWidth = [0, 0, 0, 0, 0];
  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      initStrings();
      initButtons();
      firstBuild = false;
    }
    return QuizCardScreenPauseObserverWrapper(
      cardType: widget.cardType,
      child: PlaytimeClockWrapper(
        routine: () {
          playtime++;
        },
        child: CorrectionWrapper(
          quizCardID: widget.knowledge[0].id,
          incorrectMessage: AppLocalizations.of(context)!
              .statementCompleteSelectionCorrectFillInWouldHaveBeenCorrect(
                  correctFillIn),
          onComplete: widget.onComplete,
          errors: errors,
          playtime: playtime,
          revealed: revealed,
          child: Column(
            children: [
              QuestionCard(
                question: AppLocalizations.of(context)!
                    .statementCompleteSelectionWhichOneFits,
                color: widget.color,
              ),
              // The sentence
              FoloCard(
                color: widget.color,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  child: SingleChildScrollView(
                    child: _SentenceWithSelection(
                      beforeSelectable: beforeSelectable,
                      selectable: selectable,
                      afterSelectable: afterSelectable,
                      color: widget.color,
                    ),
                  ),
                ),
              ),
              // The possible answers
              Flexible(
                child: FoloCard(
                  color: widget.color,
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    child: Wrap(
                      children: [
                        for (int i = 0; i < buttonText.length; i++)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SelectableButton(
                              hasCorrectStatement: widget
                                  .statements[0].correctFillIns
                                  .contains(buttonText[i]),
                              revealed: revealed,
                              width: buttonWidth[i],
                              height: 50,
                              selected: buttonSelected[i],
                              onChanged: () => selectButton(i),
                              child: FittedBox(
                                child: TexText(
                                  rawString: buttonText[i],
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              // The submit button
              SizedBox(
                width: double.infinity,
                height: 140,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                      child: FoloButton(
                        height: 60,
                        width: double.infinity,
                        color: widget.color,
                        child: TexText(
                          rawString: AppLocalizations.of(context)!.done,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          correct();
                          setState(() {
                            revealed = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Sets the error count to 1 if the user did not input the right answer
  void correct() {
    for (int i = 0; i < buttonText.length; i++) {
      if (buttonSelected[i] !=
          widget.statements[0].correctFillIns.contains(buttonText[i])) {
        errors = 1;
        return;
      }
    }
  }

  /// Unselects the previously selected button and selects the button
  /// with the given index
  void selectButton(int index) {
    //At the start no button is selected, this evaluates to true.
    //Assuming that at most 1 button is selected at a time, this evaluates
    //to false if and only if the i'th button has been selected before
    if (buttonSelected[index] != true) {
      Future.delayed(const Duration(milliseconds: 50))
          .whenComplete(() => setState(() {
                selectable = !buttonSelected[index] ? buttonText[index] : " ";
                // Now all buttons are deselected except the one with the given index
                buttonSelected = [for (int i = 0; i < 5; i++) i == index];
              }));
    } else {
      buttonSelected[index] = false;
      Future.delayed(const Duration(milliseconds: 50))
          .whenComplete(() => setState(() {
                selectable = " ";
              }));
    }
  }

  /// Constructs the Strings beforeSelectable and AfterSelectable
  void initStrings() {
    // Constructing The Text before the Selectable
    int index = 0;
    while (widget.statements[0].contentItems[index] != "" &&
        index < widget.statements[0].contentItems.length) {
      beforeSelectable += " " + widget.statements[0].contentItems[index];
      index++;
    }
    beforeSelectable = beforeSelectable.trim();
    // Skipping the empty String
    index++;
    //construction the text after selectable
    while (index < widget.statements[0].contentItems.length) {
      afterSelectable += " " + widget.statements[0].contentItems[index];
      index++;
    }
  }

  /// Initializes the selectable Text within the buttons
  void initButtons() {
    correctFillIn = widget.statements[0].correctFillIns[0];
    List<String> incorrectFillIns = widget.statements[0].incorrectFillIns;

    //Getting rid of all non-latex-math-strings
    incorrectFillIns = incorrectFillIns
        .where((element) => !incorrectFillIns.contains("\$\$$element\$\$"))
        .toList();
    //Getting rid of all elements that also exist as $$\text{element}$$
    incorrectFillIns = incorrectFillIns
        .where(
            (element) => !incorrectFillIns.contains("\$\$\\text{$element}\$\$"))
        .toList();
    Random random = Random(DateTime.now().hashCode);
    incorrectFillIns.shuffle(random);
    incorrectFillIns.sublist(0, min(incorrectFillIns.length, 4));
    buttonText.add(correctFillIn);
    incorrectFillIns.shuffle(random);
    if (incorrectFillIns.length > 4) {
      incorrectFillIns = incorrectFillIns.sublist(0, 4);
    }
    buttonText.addAll(incorrectFillIns);
    buttonText.shuffle(random);

    for (int i = 0; i < buttonText.length; i++) {
      buttonWidth[i] = max(20.0 * buttonText[i].length, 60);
    }
  }
}

/// The sentence that is to be fulfilled with a Container that may contain the
/// selected fillin
class _SentenceWithSelection extends StatelessWidget {
  final String beforeSelectable;
  final String selectable;
  final String afterSelectable;
  final Color color;
  const _SentenceWithSelection({
    required this.beforeSelectable,
    required this.selectable,
    required this.afterSelectable,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // a wrap of words that have the content before the selectable item
    // then an animated blank field and then the rest of the content
    return TexText.withWidgets(content: [
      beforeSelectable.trim(), // The animated blank field
      Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: AnimatedContainer(
          decoration: BoxDecoration(
            gradient: selectable == ""
                ? const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 240, 240, 240),
                      Color.fromARGB(255, 240, 240, 240),
                      Color.fromARGB(255, 240, 240, 240),
                      Color.fromARGB(255, 230, 230, 230)
                    ],
                    transform: GradientRotation(pi / 2),
                  )
                : null,
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
            border: Border.all(width: 3, color: color),
          ),
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minWidth: 60),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: TexText(
              rawString: selectable,
            ),
          ),
        ),
      ),
      afterSelectable.trim(),
    ]);
  }
}
