import 'dart:math';

import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import 'package:flutter/material.dart';
import 'package:focuslocus/knowledge/knowledge_statement.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/quiz_card_items/quiz_card_help_dialog.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/correction_wrapper.dart';
import 'package:focuslocus/widgets/quiz_card_items/question_card.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/playtime_clock_wrapper.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/quiz_card_screen_pause_observer_wrapper.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';

/// The most cognitively straining kind of Statement Screen: The user gets a statement and
/// fills in the missing word using their keyboard
class StatementCompleteTypingScreen extends QuizCardScreen {
  final List<KnowledgeStatement> statements;

  const StatementCompleteTypingScreen({
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
          cardType: "statement_complete_typing",
          knowledge: statements,
          onComplete: onComplete,
          color: color,
          key: key,
        );

  @override
  _StatementCompleteTypingScreenState createState() =>
      _StatementCompleteTypingScreenState();
  @override
  void showHelpDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => QuizCardHelpDialog(children: [
              FoloCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Fülle die Lücke mit dem richtigen Wort aus",
                      textAlign: TextAlign.center,
                      style: (Theme.of(context).textTheme.headline6 ??
                              const TextStyle())
                          .copyWith(color: ColorTransform.textColor(color)),
                    ),
                  ),
                  color: color),
              FoloCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const Text("Tippe die Lücke an"),
                        Image.asset(
                            "assets/help_dialogs/statement_complete_typing_screen_empty.png")
                      ],
                    ),
                  ),
                  color: color),
              FoloCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const Text(
                            "Gib nun das Wort ein und Tippe auf Enter oder 'Fertig'"),
                        Image.asset(
                            "assets/help_dialogs/statement_complete_typing_screen_full.png")
                      ],
                    ),
                  ),
                  color: color)
            ], color: color));
  }
}

class _StatementCompleteTypingScreenState
    extends State<StatementCompleteTypingScreen> {
  int playtime = 0;
  int errors = 0;
  bool revealed = false;
  bool firstBuild = true;
  List<Widget> widgets = [];
  TextField textField = const TextField();
  String textFieldContent = "";
  List<String> correctFillInsLowerCase = [];
  @override
  Widget build(BuildContext context) {
    // First everything that occurs before the textfiels
    if (firstBuild) {
      int currentString = 0;
      String stringBeforeTextField = "";
      while (currentString < widget.statements[0].contentItems.length &&
          widget.statements[0].contentItems[currentString] != "") {
        stringBeforeTextField +=
            widget.statements[0].contentItems[currentString] + "";
        currentString++;
      }

      stringBeforeTextField = stringBeforeTextField.trim();
      if (stringBeforeTextField != "") {
        widgets = TexText(rawString: stringBeforeTextField).getWidgets(context);
      }
      // Now the textfield itself (the blank)
      textField = TextField(
        readOnly: revealed,
        autofocus: false,
        autocorrect: false,
        decoration: InputDecoration(
          focusColor: widget.color,
          hoverColor: widget.color,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.color, width: 3),
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: widget.color, width: 3),
            gapPadding: 0,
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
        onChanged: (text) {
          textFieldContent = text;
        },
        onSubmitted: (submittedFillIn) {
          correct(submittedFillIn);
          setState(() {
            revealed = true;
          });
        },
      );

      //calculating the length of the longest correct word.
      List<int> lengths = widget.statements[0].correctFillIns
          .map<int>((e) => e.length)
          .toList();
      int maxLength = 0;
      for (int length in lengths) {
        maxLength = max(length, maxLength);
      }
      widgets.add(SizedBox(width: max(maxLength * 20, 60), child: textField));

      // Now the trailing end. CurrentString is now at the "", so we increase it
      currentString++;
      String stringAfterTextField = "";
      while (currentString < widget.statements[0].contentItems.length) {
        stringAfterTextField +=
            widget.statements[0].contentItems[currentString] + "";
        currentString++;
      }
      stringAfterTextField = stringAfterTextField.trim();
      if (stringAfterTextField != "") {
        widgets.addAll(
            TexText(rawString: stringAfterTextField).getWidgets(context));
      }

      firstBuild = false;
    }

    return QuizCardScreenPauseObserverWrapper(
      cardType: widget.cardType,
      child: CorrectionWrapper(
        quizCardID: widget.knowledge[0].id,
        incorrectMessage:
            "Richtig wäre \"" + widget.statements[0].correctFillIns[0] + "\"",
        onComplete: widget.onComplete,
        errors: errors,
        playtime: playtime,
        revealed: revealed,
        child: PlaytimeClockWrapper(
          routine: () {
            playtime++;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              QuestionCard(
                question: "Vervollständige die Aussage!",
                color: widget.color,
              ),
              // This makes sure that the user cannot input an answer after submitting
              IgnorePointer(
                ignoring: revealed,
                child: FoloCard(
                  color: widget.color,
                  // The actual sentence with the blank
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: widgets,
                  ),
                ),
              ),
              Expanded(
                child: Container(),
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
                        width: double.infinity,
                        color: widget.color,
                        child: TexText(
                          rawString: "Fertig",
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          correct(textFieldContent);
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

  /// Compares the submitted string with the correct/incorrect fillins, while
  /// ignoring minor spelling mistakes. If the levenstein distance ratio between
  /// a correct string and the submitted string fall under 90, this is seen as
  /// an error. Similarly, if the levenstein distance ratio is at least as high
  /// between the input and an incorrect answer, this will be seen as incorrect
  /// too.
  void correct(String submittedFillIn) {
    List<String> correctFillInsLowercase = widget.statements[0].correctFillIns
        .map((e) => e.toLowerCase())
        .toList();
    List<String> incorrectFillInsLowercase = widget
        .statements[0].incorrectFillIns
        .map((e) => e.toLowerCase())
        .toList();
    int highestRatioCorrect = 0;
    submittedFillIn = submittedFillIn.toLowerCase();
    for (String correctFillIn in correctFillInsLowercase) {
      highestRatioCorrect =
          max(highestRatioCorrect, ratio(correctFillIn, submittedFillIn));
    }

    int highestRatioIncorrect = 0;
    for (String incorrectFillIn in incorrectFillInsLowercase) {
      highestRatioIncorrect =
          max(highestRatioIncorrect, ratio(incorrectFillIn, submittedFillIn));
    }
    if (highestRatioIncorrect >= highestRatioCorrect ||
        highestRatioCorrect < 90) {
      errors = 1;
    }
  }
}
