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
import 'package:focuslocus/util/perception_adjusted_colors.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The screen that is shown after all questions in the quiz have been answered.
/// It gives the user a brief overview of the ammount of mistakes that have been
/// made and the right answers that have been given
class QuizFinishedScreen extends StatelessWidget {
  /// How many questions were answered correctly?
  final int correct;

  /// How many questions were answered incorrectly?
  final int incorrect;

  /// The color of the quizFinished screen. In normal quizzes the deck color
  final Color color;

  /// The function that is called before the quiz is closed. In quiz_screen.dart,
  /// for example, it is used to increment the timesPlayed value of the deck.
  final Function onFinish;

  const QuizFinishedScreen({
    required this.onFinish,
    this.color = Colors.blue,
    required this.correct,
    required this.incorrect,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.quizFinishedScreenYouDidIt,
            style: (Theme.of(context).textTheme.headline3 ?? const TextStyle())
                .copyWith(color: color),
            textAlign: TextAlign.center,
          ),
          TweenAnimationBuilder(
            tween: Tween<double>(
                begin: 0,
                end: correct.toDouble() / (correct + incorrect).toDouble()),
            duration: const Duration(seconds: 1),
            builder: (context, double value, child) => FoloCard(
              color: color,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: value,
                              backgroundColor: PerceptionAdjustedColors.bad,
                              color: PerceptionAdjustedColors.good,
                              strokeWidth: 5,
                            ),
                          ),
                        ),
                        Text(
                          (value * 100).round().toString() + "%",
                          style: (Theme.of(context).textTheme.bodyText1 ??
                                  const TextStyle())
                              .copyWith(fontSize: 25),
                        ),
                      ],
                      alignment: Alignment.center,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 4, bottom: 4),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: PerceptionAdjustedColors.good,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15))),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!
                                .quizFinishedScreenCorrect +
                            ": $correct",
                        style: (Theme.of(context).textTheme.bodyText1 ??
                                const TextStyle())
                            .copyWith(fontSize: 25, color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 4, bottom: 4),
                    decoration: BoxDecoration(
                        color: PerceptionAdjustedColors.bad,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15))),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!
                                .quizFinishedScreenIncorrect +
                            ": $incorrect",
                        style: (Theme.of(context).textTheme.bodyText1 ??
                                const TextStyle())
                            .copyWith(fontSize: 25, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          FoloButton(
            height: 60,
            shouldStretch: true,
            color: color,
            child: incorrect < 3
                ? Text(AppLocalizations.of(context)!.quizFinishedScreenYay)
                : Text(AppLocalizations.of(context)!.quizFinishedScreenFinally),
            onPressed: () {
              onFinish();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
