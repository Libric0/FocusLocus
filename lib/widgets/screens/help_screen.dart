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
import 'package:focuslocus/local_storage/learning_metadata_storage.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The screen that makes the support e-mail adress accessible to users in case
/// they have a question/bug report regarding the application
class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  bool firstBuild = true;
  List<String> cardTypes = LearningMetadataStorage.getAllCardTypes();
  List<DropdownMenuItem<String>> cardTypeMenuItems = [];
  int selectedTypeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTransform.scaffoldBackgroundColor(Colors.blue),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        shadowColor: Colors.blue,
        title: Text(AppLocalizations.of(context)!.help),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: FoloCard(
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!
                    .ifYouNeedAssistanceOrEncounteredABugWriteAMailTo),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(child: Text(Config.helpEmail)),
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      width: 1,
                      height: 30,
                      color: Colors.grey,
                    ),
                    IconButton(
                        onPressed: () {
                          launch(Mailto(
                            to: [Config.helpEmail],
                            subject: "[FocusLocus] Question regarding:",
                          ).toString())
                              .onError((error, stackTrace) {
                            // When the user's operating system does not support opening mailto links
                            Clipboard.setData(
                                ClipboardData(text: Config.helpEmail));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .copiedEmailAdressToClipboard)));
                            return true;
                          });
                        },
                        icon: const Icon(Icons.mail_outline)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
