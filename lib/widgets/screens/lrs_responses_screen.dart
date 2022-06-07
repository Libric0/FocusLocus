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
import 'package:focuslocus/web_communication/lrs_sync.dart';
import 'package:focuslocus/local_storage/user_storage.dart';
import 'package:tincan/tincan.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A screen that is only used for debug purposes. Displays all responses from the
/// LRS. Will only appear in the menu, if [testLRSSync] is set to true and the
/// application is in debug mode.
class LrsResponsesScreen extends StatelessWidget {
  const LrsResponsesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.lrsResponses),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
              title: Text("ADHD Uploaded: " +
                  UserStorage.hasUploadedADHDType.toString())),
          ListTile(
              title: Text("Has Consent: " + UserStorage.hasConsent.toString())),
          for (LRSResponse response in LrsSync.lastresponses)
            ListTile(title: Text(response.success.toString()))
        ],
      ),
    );
  }
}
