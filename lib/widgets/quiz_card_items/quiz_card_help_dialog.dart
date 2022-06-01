import 'package:flutter/material.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A dialog that shows helpful Information about a certain quiz card, e.g. how
/// it works
class QuizCardHelpDialog extends Dialog {
  final List<Widget> children;
  final Color color;
  const QuizCardHelpDialog(
      {required this.children, required this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorTransform.scaffoldBackgroundColor(color),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(children: children),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 10),
            child: FoloButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
