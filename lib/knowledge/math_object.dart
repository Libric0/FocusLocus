// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

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
