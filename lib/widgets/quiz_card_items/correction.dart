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
import 'package:flutter/services.dart';
import 'package:focuslocus/config.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:focuslocus/util/style_constants.dart';
import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Correction extends StatelessWidget {
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
  const Correction({
    Key? key,
    this.correctMessage,
    this.incorrectMessage,
    this.errors = 0,
    this.commissionErrors = 0,
    this.omissionErrors = 0,
    required this.playtime,
    this.easy = false,
    this.height = 140,
    this.revealed = false,
    required this.onComplete,
    required this.quizCardID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      curve: Curves.linear,
      duration: const Duration(milliseconds: 100),
      tween: Tween<double>(begin: height, end: height * (revealed ? 0 : 1)),
      builder: (_, double offset, __) => Transform.translate(
        offset: Offset(0.0, offset),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: const [StyleConstants.cardBoxShadow],
              color: errors + commissionErrors + omissionErrors == 0
                  ? Colors.green
                  : Colors.red,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        child: IconButton(
                            onPressed: () {
                              try {
                                launch(Mailto(
                                  to: [Config.helpEmail],
                                  subject:
                                      "[FocusLocus] Question regarding: \"$quizCardID\"",
                                ).toString());
                              } catch (e) {
                                // When the user's operating system does not support opening mailto links
                                Clipboard.setData(
                                    ClipboardData(text: Config.helpEmail));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(AppLocalizations.of(
                                                context)!
                                            .copiedEmailAdressToClipboard)));
                              }
                            },
                            icon: const Icon(
                              Icons.live_help,
                              color: Colors.white,
                              size: 30,
                            )),
                      ),
                      Expanded(
                        child: FittedBox(
                          child: TexText(
                            rawString:
                                errors + commissionErrors + omissionErrors == 0
                                    ? (correctMessage ??
                                        AppLocalizations.of(context)!
                                            .correctionCorrectMessage)
                                    : (incorrectMessage ??
                                        AppLocalizations.of(context)!
                                            .correctionIncorrectMessage),
                            style: (Theme.of(context).textTheme.headline5 ??
                                    const TextStyle())
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12.0, right: 12, bottom: 12),
                  child: FoloButton(
                    height: 60,
                    width: double.infinity,
                    color: Colors.white,
                    child: Icon(
                      Icons.fast_forward,
                      size: 40,
                      color: errors + commissionErrors + omissionErrors == 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    onPressed: () {
                      onComplete(
                        playtime: playtime,
                        errors: errors,
                        commissionErrors: commissionErrors,
                        easy: easy,
                        omissionErrors: omissionErrors,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
