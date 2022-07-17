// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'package:petitparser/petitparser.dart';

class TexTextDefinition extends GrammarDefinition {
  /// Sequences that should not occur within a charPrimitive
  List<Parser> escapedSequences = [
    /// Indicates the start of a math block
    string("\\("),

    /// Indicates the start of inline code
    string("`"),

    /// Indicates the start of a code block
    string("```"),

    /// A backslash, which is also used to escape characters, so has to be escaped itself
    string("\\"),

    /// Indicates the start of an italics text block
    string("*"),

    /// Indicates the start of a bold text block
    string("**"),

    /// Indicates of bold and italics
    string("***"),
  ];
  @override
  Parser start() => ref0(compound).end();

  Parser atom() {
    return [
      ref0(textBoldItal),
      ref0(textBold),
      ref0(textItal),
      ref0(math),
      ref0(codeBlock),
      ref0(inlineCode),
      // ref0(orderedList),
      // ref0(unorderedList),
      ref0(textNormal),
    ].toChoiceParser();
  }

  Parser compound() => ref0(atom).repeat(1, 2000);

  /// Sequences that can be within a regular textblock
  Parser seqPrimitive() => ref0(seqNormal) | ref0(seqEscape);
  Parser seqNormal() {
    Parser ret = escapedSequences[0].not();
    for (int i = 1; i < escapedSequences.length; i++) {
      ret = ret & escapedSequences[i].not();
    }
    return ret & any();
  }

  Parser seqEscape() {
    Parser ret =
        (char("\\") & escapedSequences[0]).map((value) => value.sublist(1));
    for (int i = 1; i < escapedSequences.length; i++) {
      ret = ret |
          (char("\\") & escapedSequences[i]).map((value) => value.sublist(1));
    }
    return ret;
  }

  Parser textNormal() =>
      (ref0(seqPrimitive).star()).map((value) => resultToString(value).join());

  Parser textBoldItal() => (string("***") & ref0(textNormal) & string("***"));

  Parser textBold() => (string("**") & ref0(textNormal) & string("**"));

  Parser textItal() => (string("*") & ref0(textNormal) & string("*"));

  Parser math() => (string("\\(") & ref0(textNormal) & string("\\)"));

  Parser codeBlock() => (string("```") & ref0(textNormal) & string("```"));

  Parser inlineCode() => (string("`") & ref0(textNormal) & string("`"));
}

List<dynamic> resultToString(List list) {
  List<dynamic> ret = [];
  for (var child in list) {
    if (child is List<dynamic>) {
      List<dynamic> childFailureFree = resultToString(child);
      if (childFailureFree.isNotEmpty && childFailureFree != [""]) {
        ret.add(childFailureFree.join());
      }
    } else if (child is! Result && child != "") {
      ret.add(child);
    }
  }
  return ret;
}

List<dynamic> parse(String input) {
  Parser texTextParser = TexTextDefinition().build();
  Result res = texTextParser.parse(input);
  return (removeFailures(res.value));
}

List<dynamic> removeFailures(List list) {
  List<dynamic> ret = [];
  for (var child in list) {
    if (child is List<dynamic>) {
      List<dynamic> childFailureFree = removeFailures(child);
      if (childFailureFree.length > 0 && childFailureFree != [""]) {
        ret.add(childFailureFree);
      }
    } else if (child is! Result && child != "") {
      ret.add(child);
    }
  }
  return ret;
}
