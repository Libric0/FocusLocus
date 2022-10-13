// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:focuslocus/knowledge/course.dart';
import 'package:focuslocus/knowledge/deck.dart';
import 'package:focuslocus/local_storage/course_metadata_storage.dart';
import 'package:focuslocus/widgets/screens/deck_screen.dart';

import '../ui_elements/deck_screen_top_bar.dart';

/// The screen that the user sees when starting up the application (after the
/// welcome screen). It displays a list of deck screens in a horizontal list.
class CourseOverview extends StatefulWidget {
  final Course course;
  final double selectedDeck;
  const CourseOverview({Key? key, required this.course, this.selectedDeck = 0})
      : super(key: key);

  @override
  _CourseOverviewState createState() => _CourseOverviewState();
}

class _CourseOverviewState extends State<CourseOverview> {
  bool firstBuild = true;
  late PageController pageController;
  late double selectedDeck;
  List<DeckScreen> deckScreens = [];
  @override
  void initState() {
    selectedDeck = widget.selectedDeck < widget.course.decks.length
        ? widget.selectedDeck
        : 0;
    pageController = PageController(
      initialPage: selectedDeck.toInt(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      deckScreens = generateDeckScreens(context);
      firstBuild = false;
    }
    Color currentDeckColor =
        widget.course.decks[selectedDeck.toInt()].deckColor;

    return Column(
      children: [
        // The animated top bar
        DeckScreenTopBar(
          deckColor: currentDeckColor,
          courseName: widget.course.title,
        ),
        Expanded(
          child: Stack(
            children: [
              // The deck-screens
              PageView(
                allowImplicitScrolling: true,
                controller: pageController,
                children: deckScreens,
                onPageChanged: (value) {
                  setState(() {
                    selectedDeck = value.toDouble();
                    currentDeckColor =
                        widget.course.decks[selectedDeck.toInt()].deckColor;
                    CourseMetadataStorage.setCurrentDeckIndex(
                        widget.course.id, selectedDeck.toInt());
                  });
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: DotsIndicator(
                  dotsCount: deckScreens.length,
                  onTap: (position) {
                    setState(() {
                      pageController.animateToPage(position.toInt(),
                          curve: Curves.linear,
                          duration: const Duration(milliseconds: 200));
                    });
                  },
                  position: selectedDeck,
                  decorator: DotsDecorator(
                    activeColor: currentDeckColor,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  List<DeckScreen> generateDeckScreens(BuildContext context) {
    List<DeckScreen> ret = [];
    for (Deck deck in widget.course.decks) {
      ret.add(DeckScreen(
        deck,
        widget.course.language,
        keywordBackground: DeckScreen.generateKeywordBackground(context, deck),
      ));
    }
    return ret;
  }
}
