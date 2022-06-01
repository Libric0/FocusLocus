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
