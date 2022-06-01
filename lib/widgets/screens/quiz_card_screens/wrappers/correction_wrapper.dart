import 'package:flutter/material.dart';
import 'package:focuslocus/widgets/quiz_card_items/correction.dart';

class CorrectionWrapper extends StatelessWidget {
  final Widget child;
  final bool revealed;
  final double height;
  final int errors;
  final int commissionErrors;
  final int omissionErrors;
  final int playtime;
  final String? correctMessage;
  final String? incorrectMessage;
  final bool easy;
  final String quizCardID;
  final Function({
    int errors,
    int commissionErrors,
    int omissionErrors,
    required int playtime,
    bool easy,
  }) onComplete;
  const CorrectionWrapper(
      {required this.child,
      required this.revealed,
      this.height = 140,
      this.errors = 0,
      this.commissionErrors = 0,
      this.omissionErrors = 0,
      required this.onComplete,
      this.correctMessage,
      this.incorrectMessage,
      this.easy = false,
      required this.playtime,
      required this.quizCardID,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          child: Correction(
            onComplete: onComplete,
            playtime: playtime,
            commissionErrors: commissionErrors,
            correctMessage: correctMessage,
            easy: easy,
            errors: errors,
            height: height,
            incorrectMessage: incorrectMessage,
            omissionErrors: omissionErrors,
            revealed: revealed,
            quizCardID: quizCardID,
          ),
        )
      ],
    );
  }
}
