import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        title: const Text("Hilfe"),
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
                    const FittedBox(
                        child: Text("focuslocus@librico.mozmail.com")),
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
                            to: ["focuslocus@librico.mozmail.com"],
                            subject: "[FocusLocus] Question regarding:",
                          ).toString())
                              .onError((error, stackTrace) {
                            // When the user's operating system does not support opening mailto links
                            Clipboard.setData(const ClipboardData(
                                text: "focoslocus@librico.mozmail.com"));
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
