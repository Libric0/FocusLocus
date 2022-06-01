import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:focuslocus/knowledge/quiz_course.dart';
import 'package:focuslocus/knowledge/quiz_deck.dart';
import 'package:focuslocus/local_storage/course_metadata_storage.dart';
import 'package:focuslocus/widgets/screens/deck_screen.dart';

import '../ui_elements/deck_screen_top_bar.dart';

/// The screen that the user sees when starting up the application (after the
/// welcome screen). It displays a list of deck screens in a horizontal list.
class CourseOverview extends StatefulWidget {
  final QuizCourse course;
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
    selectedDeck = widget.selectedDeck;
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
          courseName: widget.course.id,
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
    for (QuizDeck deck in widget.course.decks) {
      ret.add(DeckScreen(
        deck,
        widget.course.language,
        keywordBackground: DeckScreen.generateKeywordBackground(context, deck),
      ));
    }
    return ret;
  }
}
