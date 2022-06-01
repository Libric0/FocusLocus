import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TexText extends StatelessWidget {
  final String rawString;
  late final List<String> strings;
  final TextStyle? style;

  TexText({
    Key? key,
    required this.rawString,
    this.style = const TextStyle(
        color: Colors.black, fontFamily: 'OpenDyslexic', fontSize: 20),
  }) : super(key: key) {
    strings = processRawString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Wrap(
        children: getWidgets(context),
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
      ),
    );
  }

  int get length => rawString.length;

  List<Widget> getWidgets(context) {
    TextStyle actualTextStyle = (Theme.of(context).textTheme.bodyText1 ??
            const TextStyle(fontFamily: 'OpenDyslexic'))
        .merge(style);
    return [
      for (String string in strings)
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: string.startsWith("\$\$") &&
                  string.endsWith("\$\$") &&
                  string.length >= 5
              ? Math.tex(
                  string.substring(2, string.length - 2),
                  options: MathOptions(
                      fontSize: actualTextStyle.fontSize,
                      color: actualTextStyle.color ?? Colors.black),
                )
              : Text(
                  string,
                  style: actualTextStyle,
                ),
        )
    ];
  }

  /// Takes the raw string and turns it into a list of strings that can be
  /// processed further
  List<String> processRawString() {
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
      if (rawString[i] != '\$' && currentDollars.isOdd) {
        currentDollars--;
      }
      if (currentDollars == 0 && rawString[i] == ' ') {
        ret.add(currentPart.substring(0, currentPart.length - 1));
        currentPart = '';
      }
      // Here we read a dollar sign and split if needed
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
