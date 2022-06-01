import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';

/// An object that is written in tex and differentiable from other math objects.
/// It may be stored in a mathUniverse and accessed from there. In the future,
/// math objects can contain additional information, such as a definition, important
/// theorems etc.
class MathObject {
  String mathObjectId;
  String rawString;

  MathObject({
    required this.mathObjectId,
    this.rawString = "",
  }) {
    if (rawString == "") {
      rawString = r"$$\text{" + mathObjectId + r"}$$";
    }
    mathObjectId = "mathObject." + mathObjectId;
  }

  /// Returns a TexText widget containing the mathobject in TeX representation
  TexText getWidget() {
    return TexText(rawString: rawString);
  }
}
