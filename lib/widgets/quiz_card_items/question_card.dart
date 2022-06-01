import 'package:flutter/material.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';

import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';

class QuestionCard extends StatelessWidget {
  /// The question in TexText notation
  final String question;
  final Color color;
  const QuestionCard({
    required this.question,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FoloCard(
      color: color,
      child: Center(
        child: TexText(
          rawString: question,
          style: TextStyle(
            color: ColorTransform.textColor(color),
          ),
        ),
      ),
    );
  }
}
