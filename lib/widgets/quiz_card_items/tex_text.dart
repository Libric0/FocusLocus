// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:focuslocus/util/tex_text_parser.dart';
import 'package:petitparser/petitparser.dart';
import 'dart:math';

class TexText extends StatelessWidget {
  final List content;
  final TextStyle? style;

  const TexText._({
    Key? key,
    required this.content,
    this.style = const TextStyle(
        color: Colors.black, fontFamily: 'OpenDyslexic', fontSize: 20),
  }) : super(key: key);

  factory TexText({Key? key, required String rawString, TextStyle? style}) {
    return TexText._(key: key, content: parse(rawString), style: style);
  }

  factory TexText.withWidgets(
      {Key? key, required List content, TextStyle? style}) {
    List parsedContent = [];
    for (var contentItem in content) {
      if (contentItem is String) {
        parsedContent.addAll(parse(contentItem));
      } else {
        parsedContent.add(contentItem);
      }
    }
    return TexText._(key: key, content: parsedContent, style: style);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (List<InlineSpan> line in getLines(context))
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: RichText(
              text: TextSpan(children: line),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  int get length {
    int ret = 0;
    for (var contentItem in content) {
      try {
        ret += int.parse(contentItem.length.toString());
      } catch (e) {
        ret++;
      }
    }
    return ret;
  }

  /// Generates a list of Text-Lines that should be displayed. Can either
  /// Contain (formatted) text, math or a widget
  List<List<InlineSpan>> getLines(context) {
    TextStyle actualTextStyle = (Theme.of(context).textTheme.bodyText1 ??
            const TextStyle(fontFamily: 'Sans-Serif', height: 1.2))
        .merge(style);
    List<List<InlineSpan>> ret = [];
    List<InlineSpan> currentLine = [];
    for (var contentItem in content) {
      if (contentItem is String) {
        List<String> lineStrings = contentItem.split("\n");
        for (int i = 0; i < lineStrings.length; i++) {
          String lineString = lineStrings[i];

          // Empty String
          if (lineString == "") {
            continue;
          }
          //Text
          currentLine.add(
            TextSpan(text: lineString, style: actualTextStyle),
          );

          if (i < lineStrings.length - 1) {
            ret.add(currentLine);
            currentLine = [];
          }
        }
      } else if (contentItem is List) {
        // Math
        if (contentItem.first == "\\(" &&
            contentItem.last == "\\)" &&
            contentItem.length == 3) {
          currentLine.add(
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(top: 0.1, bottom: 0.1),
                child: Math.tex(
                  contentItem[1],
                  options: MathOptions(
                    fontSize: (actualTextStyle.fontSize ?? 20) * 1.1,
                    color: actualTextStyle.color ?? Colors.black,
                    style: MathStyle.text,
                  ),
                ),
              ),
            ),
          );
        } else if (contentItem.first == "*" &&
            contentItem.last == "*" &&
            contentItem.length == 3) {
          //Italic Text
          currentLine.add(
            TextSpan(
              text: contentItem[1],
              style: actualTextStyle.copyWith(fontStyle: FontStyle.italic),
            ),
          );
        }
        // Bold
        else if (contentItem.first == "**" &&
            contentItem.last == "**" &&
            contentItem.length == 3) {
          currentLine.add(
            TextSpan(
              text: contentItem[1],
              style: actualTextStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }
        // Bold Italic
        else if (contentItem.first == "***" &&
            contentItem.last == "***" &&
            contentItem.length == 3) {
          currentLine.add(
            TextSpan(
              text: contentItem[1],
              style: actualTextStyle.copyWith(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
          );
        }
        // Inline Code
        else if (contentItem.first == "`" &&
            contentItem.last == "`" &&
            contentItem.length == 3) {
          currentLine.add(
            TextSpan(
              text: contentItem[1],
              style: actualTextStyle.copyWith(fontFamily: "monospace"),
            ),
          );
        }
      } else if (contentItem is Widget) {
        currentLine.add(WidgetSpan(
            child: contentItem,
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic));
      } else {
        throw Exception("The content of the " +
            runtimeType.toString() +
            "contains something that is neither String nor widget. Remove that item.\nContent: " +
            content.toString());
      }
    }
    ret.add(currentLine);
    return ret;
  }
}
