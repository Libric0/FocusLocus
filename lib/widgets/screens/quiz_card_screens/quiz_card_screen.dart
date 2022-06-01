import 'package:flutter/material.dart';
import 'package:focuslocus/knowledge/knowledge_item.dart';

abstract class QuizCardScreen extends StatefulWidget {
  /// A callback-Function that is called when a card is completed. The Completion
  /// Type indicates how successfully the assignment was completed.
  ///
  /// Different kinds of quizzes may implement different onComplete callbacks.
  final void Function({
    int errors,
    int commissionErrors,
    int omissionErrors,
    required int playtime,
    bool easy,
  }) onComplete;

  /// A list of quiz-knowledge items that may be used for this card. The list could
  /// be implemented as only having one element in the given subclass.
  final List<KnowledgeItem> knowledge;
  final Color color;
  final String cardType;
  const QuizCardScreen({
    required this.onComplete,
    required this.knowledge,
    required this.cardType,
    this.color = Colors.blue,
    Key? key,
  }) : super(key: key);

  ///Shows a help dialog explaining the mechanics of this quiz Card
  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ClipRRect(
        child: Dialog(
          insetPadding: const EdgeInsets.all(0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Text(cardType),
              )),
        ),
      ),
    );
  }
}
