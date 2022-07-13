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
    return TexText._(key: key, content: [rawString], style: style);
  }

  factory TexText.withWidgets(
      {Key? key, required List content, TextStyle? style}) {
    return TexText._(key: key, content: content, style: style);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (List<InlineSpan> line in getLines(context))
          RichText(
            text: TextSpan(text: "", children: line),
            textAlign: TextAlign.center,
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
  /// Contain text, math or a widget
  List<List<InlineSpan>> getLines(context) {
    TextStyle actualTextStyle = (Theme.of(context).textTheme.bodyText1 ??
            const TextStyle(fontFamily: 'OpenDyslexic'))
        .merge(style);

    List<List<InlineSpan>> ret = [];
    List<InlineSpan> currentLine = [];
    for (var contentItem in content) {
      if (contentItem is String) {
        List<String> lineStrings = contentItem.split("\n");
        for (int i = 0; i < lineStrings.length; i++) {
          String lineString = lineStrings[i].trim();
          List<String> subStrings = processRawString(lineString);
          for (String substring in subStrings) {
            // Empty String
            if (substring == "") {
              continue;
            }
            // Math
            if (substring.startsWith("\$\$") &&
                substring.endsWith("\$\$") &&
                substring.length >= 5) {
              currentLine.add(
                WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: (actualTextStyle.fontSize ?? 10) * 0.25,
                        top: (actualTextStyle.fontSize ?? 10) * 0.25),

                    // Really bad hack to properly align math with other kinds of text
                    child: Math.tex(
                      "\\phantom{|}" +
                          substring.substring(2, substring.length - 2) +
                          "\\phantom{|}",
                      options: MathOptions(
                          fontSize: (actualTextStyle.fontSize ?? 20) * 1.1,
                          color: actualTextStyle.color ?? Colors.black),
                    ),
                  ),
                ),
              );
            }
            //Text
            else {
              currentLine.add(
                WidgetSpan(
                  child: Text(substring,
                      strutStyle: StrutStyle.disabled, style: actualTextStyle),
                ),
              );
            }
          }
          if (i < lineStrings.length - 1) {
            ret.add(currentLine);
            currentLine = [];
          }
        }
      } else if (contentItem is Widget) {
        currentLine.add(WidgetSpan(child: contentItem));
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

  /// Takes the raw string and turns it into a list of strings that can be
  /// processed further
  List<String> processRawString(String rawString) {
    // First we split by looking for 2 dollar signs. "Word $$math$$" would be
    // converted to ["Word", "$$math$$]
    List<String> ret = [];
    String currentPart = '';
    int currentDollars = 0;
    for (int i = 0; i < rawString.length; i++) {
      currentPart += rawString[i];
      // If we read no $ at currentDollars = 1 or 3, the $$ sequence has been interrupted
      // So either this was \$ in String (for currentDollars = 1), or \$ in Tex (for
      // currentDollars = 3), meaning a Tex-string didnt begin or end. We ignore this
      // Dollar.
      if (rawString[i] != '\$') {
        currentDollars -= currentDollars % 2;
      }
      if (currentDollars == 0 && rawString[i] == ' ') {
        ret.add(currentPart);
        currentPart = '';
        continue;
      }
      // Here we read a dollar sign and split if needed.
      if (rawString[i] == '\$') {
        // In the case that we are outside of math, we want to split the string into
        // words, so it wraps around neatly.

        // When we see the second dollar sign, currentDollars is currently at 1.
        // In that case this piece of code is run
        if (currentDollars == 1) {
          // The last and the current $ sign are already added to the current part.
          // we append the substring (non tex) without the last two chars (i.e. the $$) and
          // keep parsing.
          ret.add(currentPart.substring(0, currentPart.length - 2));
          currentPart = '\$\$';
        } else if (currentDollars == 3) {
          // The last and the current $ sign are already in current part. All we
          // have to do is append it to the list, reset the String 'currentPart'
          // and keep parsing
          ret.add(currentPart);
          currentPart = '';
        }

        // For each case, we read another dollar-sign. If we read the 4th $,
        // the corresponding code has been executed in the conditionals above, so
        // we can reset currentDollars to 0.
        currentDollars = (currentDollars + 1) % 4;
      }
    }
    ret.add(currentPart);
    // Now we turn the list of strings into a list of text- and math widgets.
    // Every string that is not sorrounded by $$ will be a text-widget, the
    // others will be math-widgets

    return ret;
  }
}
