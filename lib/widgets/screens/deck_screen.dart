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
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/screens/quiz_screen.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:focuslocus/widgets/ui_elements/folo_progress_indicator.dart';
import '../quiz_card_items/tex_text.dart';

/// A screen that displays the name of the deck, keywords in the background
/// and the play button that starts a quiz.
class DeckScreen extends StatefulWidget {
  final QuizDeck deck;
  final List<Widget> keywordBackground;

  /// The language of the course, used to launch a quiz with the correct language
  final String courseLanguage;
  const DeckScreen(this.deck, this.courseLanguage,
      {this.keywordBackground = const [], Key? key})
      : super(key: key);

  @override
  State<DeckScreen> createState() => _DeckScreenState();

  static List<Widget> generateKeywordBackground(
      BuildContext context, QuizDeck deck) {
    Random random = Random();
    List<Widget> ret = [];
    for (String keyword in deck.keywords) {
      ret.add(Positioned(
        bottom: random.nextDouble() * MediaQuery.of(context).size.height,
        right: random.nextDouble() * MediaQuery.of(context).size.width,
        child: Transform.scale(
          scale: (random.nextDouble() * 0.4) + 0.8,
          child: Transform.rotate(
            angle: (random.nextDouble() - .5) * 2,
            child: TexText(
              rawString: keyword,
              style: TextStyle(
                color: Color.alphaBlend(
                  ColorTransform.textColor(deck.deckColor).withAlpha(40),
                  ColorTransform.scaffoldBackgroundColor(deck.deckColor),
                ),
              ),
            ),
          ),
        ),
      ));
    }
    return ret;
  }
}

class _DeckScreenState extends State<DeckScreen> {
  int deckTimesPracticed = 0;
  @override
  Widget build(BuildContext context) {
    deckTimesPracticed = widget.deck.timesPracticed;
    List<Widget> internalKeywordBackground = widget.keywordBackground;
    return Container(
      color: ColorTransform.scaffoldBackgroundColor(widget.deck.deckColor),
      child: Stack(
        children: internalKeywordBackground
          ..addAll(
            [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: ColorTransform.scaffoldBackgroundColor(
                                widget.deck.deckColor),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TexText(
                            rawString: widget.deck.name,
                            style: TextStyle(
                              fontSize: 30,
                              color: ColorTransform.textColor(
                                  widget.deck.deckColor),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.deck.timesPracticed.toString() +
                                "/" +
                                widget.deck.minToPractice.toString(),
                            style: (Theme.of(context).textTheme.bodyText1 ??
                                    const TextStyle())
                                .copyWith(color: widget.deck.deckColor),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: FoloProgressIndicator(
                                color: widget.deck.deckColor,
                                backgroundColor: Colors.white,
                                value: widget.deck.timesPracticed /
                                    widget.deck.minToPractice,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          FoloButton(
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                            color: widget.deck.deckColor,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // Overriding the locale so the quiz is shown
                                  // in the course's language.
                                  builder: (context) => Localizations.override(
                                    context: context,
                                    locale: Locale(widget.courseLanguage, ''),
                                    child: Builder(builder: (context) {
                                      return QuizScreen(
                                        decks: [widget.deck],
                                        color: widget.deck.deckColor,
                                        onFinish: () {
                                          setState(
                                            () {
                                              deckTimesPracticed =
                                                  widget.deck.timesPracticed;
                                            },
                                          );
                                        },
                                      );
                                    }),
                                  ),
                                ),
                              );
                            },
                            width: 60,
                            height: 60,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
}
