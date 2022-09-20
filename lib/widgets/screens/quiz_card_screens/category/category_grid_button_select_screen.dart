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
import 'package:focuslocus/knowledge/category.dart';
import 'package:focuslocus/knowledge/knowledge_category.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/quiz_card_items/quiz_card_help_dialog.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/correction_wrapper.dart';
import 'package:focuslocus/widgets/quiz_card_items/question_card.dart';
import 'package:focuslocus/widgets/quiz_card_items/selectable_button.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/playtime_clock_wrapper.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/quiz_card_screen_pause_observer_wrapper.dart';
import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The standard Category QuizCard. A user is confronted with a 3x3 grid of
/// TruthButtons and selects which objects are contained in the category.
class CategoryGridButtonSelect extends QuizCardScreen {
  final List<Category> categories;
  const CategoryGridButtonSelect(
      {required Color color,
      required this.categories,
      required Function({
        int commissionErrors,
        bool easy,
        int errors,
        int omissionErrors,
        required int playtime,
      })
          onComplete,
      Key? key})
      : super(
            onComplete: onComplete,
            knowledge: categories,
            cardType: "category_grid_button_select",
            color: color,
            key: key);

  @override
  _CategoryGridButtonSelectState createState() =>
      _CategoryGridButtonSelectState();

  @override
  void showHelpDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => QuizCardHelpDialog(children: [
              FoloCard(
                color: color,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .categoryGridButtonChooseAllElementsThatAreInTheCategory,
                        textAlign: TextAlign.center,
                        style: (Theme.of(context).textTheme.headline6 ??
                                const TextStyle())
                            .copyWith(
                          color: ColorTransform.textColor(color),
                        ),
                      ),
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
                      SelectableButton(
                        width: 90,
                        height: 90,
                        hasCorrectStatement: true,
                        revealed: false,
                        oneLine: true,
                        texTextString: "\$\$x\$\$",
                        selected: true,
                        onChanged: () {},
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!
                            .categoryGridButtonSelectedElementsAreHighlightedInBlue,
                      ),
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
                          .categoryGridButtonAsYouTapOnDone),
                      FittedBox(
                        child: CategoryButtonGrid(
                          selected: const [
                            [false, false, true],
                            [true, true, false],
                            [false, true, false]
                          ],
                          chosenItems: [
                            [
                              AppLocalizations.of(context)!.falseWord,
                              AppLocalizations.of(context)!.falseWord,
                              AppLocalizations.of(context)!.trueWord,
                            ],
                            [
                              AppLocalizations.of(context)!.trueWord,
                              AppLocalizations.of(context)!.trueWord,
                              AppLocalizations.of(context)!.falseWord,
                            ],
                            [
                              AppLocalizations.of(context)!.falseWord,
                              AppLocalizations.of(context)!.trueWord,
                              AppLocalizations.of(context)!.falseWord,
                            ]
                          ],
                          color: color,
                          revealed: true,
                          correct: const [
                            [false, false, true],
                            [true, true, false],
                            [false, true, false]
                          ],
                          onChanged: (x, y) {},
                        ),
                      )
                    ],
                  ),
                ),
              )
            ], color: color));
  }
}

class _CategoryGridButtonSelectState extends State<CategoryGridButtonSelect> {
  int omissionErrors = 0;
  int comissionErrors = 0;
  bool revealed = false;
  bool firstBuild = true;
  int playtime = 0;
  Random random = Random();
  // Which items are selected is saved in this state to be able to make corrections
  List<List<bool>> selected = [
    [false, false, false],
    [false, false, false],
    [false, false, false]
  ];

  // A 3x3 grid of booleans. correct[x][y] is true, iff the item belongs to the
  // category
  List<List<bool>> correct = [];

  // The items that are displayed in this category
  List<List<String>> chosenItems = [];
  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      chooseItems();
      firstBuild = false;
    }
    return PlaytimeClockWrapper(
      routine: () => {playtime++},
      child: QuizCardScreenPauseObserverWrapper(
        cardType: widget.cardType,
        child: CorrectionWrapper(
          quizCardID: widget.knowledge[0].id,
          child: Column(
            children: [
              QuestionCard(
                question: widget.categories[0].questions[
                    random.nextInt(widget.categories[0].questions.length)],
                color: widget.color,
              ),
              CategoryButtonGrid(
                selected: selected,
                chosenItems: chosenItems,
                color: widget.color,
                revealed: revealed,
                correct: correct,
                onChanged: (x, y) {
                  //setState(() {
                  selected[x][y] = !selected[x][y];
                  //});
                },
              ),
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
                        color: widget.color,
                        width: double.infinity,
                        child: TexText(
                          rawString: AppLocalizations.of(context)!.done,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          correctExercise();
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          onComplete: widget.onComplete,
          omissionErrors: omissionErrors,
          commissionErrors: comissionErrors,
          errors: omissionErrors + comissionErrors,
          revealed: revealed,
          playtime: playtime,
        ),
      ),
    );
  }

  /// Chooses items from the universe of the category and marks them as correct or incorrect
  void chooseItems() {
    chosenItems = [
      for (int x = 0; x < 3; x++)
        [
          for (int y = 0; y < 3; y++)
            widget.categories[0].universe
                .elementAt(random.nextInt(widget.categories[0].universe.length))
        ]
    ];
    correct = [
      for (int x = 0; x < 3; x++)
        [
          for (int y = 0; y < 3; y++)
            widget.categories[0].inCategory.contains(chosenItems[x][y])
        ]
    ];
  }

  /// Evaluates whether the user input matches the assignment
  void correctExercise() {
    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        if (selected[x][y] != correct[x][y]) {
          if (selected[x][y]) {
            comissionErrors++;
          } else {
            omissionErrors++;
          }
        }
      }
    }
  }
}

/// The stateless widget that displays the button grid.
class CategoryButtonGrid extends StatelessWidget {
  final Color color;
  final List<List<bool>> selected;
  final List<List<bool>> correct;
  final List<List<String>> chosenItems;
  final bool revealed;
  final Function(int x, int y) onChanged;
  const CategoryButtonGrid(
      {Key? key,
      required this.selected,
      required this.chosenItems,
      required this.color,
      required this.revealed,
      required this.correct,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int x = 0; x < 3; x++)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int y = 0; y < 3; y++)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SelectableButton(
                    width: 90,
                    height: 90,
                    hasCorrectStatement: correct[x][y],
                    revealed: revealed,
                    oneLine: true,
                    texTextString: chosenItems[x][y],
                    selected: selected[x][y],
                    onChanged: () {
                      onChanged(x, y);
                    },
                  ),
                )
            ],
          )
      ],
    );
  }
}
