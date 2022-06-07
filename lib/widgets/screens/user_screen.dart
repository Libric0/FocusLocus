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
import 'package:focuslocus/local_storage/adhd_type.dart';
import 'package:focuslocus/web_communication/lrs_sync.dart';
import 'package:focuslocus/local_storage/user_storage.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The screen in which the user can see their pseudonym and retract their
/// consent for data collection.
class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorTransform.scaffoldBackgroundColor(Colors.blue),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          shadowColor: Colors.blue,
          title: Text(AppLocalizations.of(context)!.user),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          children: [
            FoloCard(
              color: Colors.blue,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.userScreenPseudonym,
                    style: (Theme.of(context).textTheme.headline5 ??
                            const TextStyle())
                        .copyWith(color: ColorTransform.textColor(Colors.blue)),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1000,
                          child: Text(
                            UserStorage.pseudonym,
                            softWrap: true,
                          ),
                        ),
                        Expanded(child: Container()),
                        Container(
                          margin: const EdgeInsets.all(8),
                          width: 1,
                          height: 70,
                          color: Colors.grey,
                        ),
                        IconButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: UserStorage.pseudonym));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  duration: const Duration(milliseconds: 500),
                                  content: Text(AppLocalizations.of(context)!
                                      .userScreenCopiedPseudonymToClipboard)));
                            },
                            icon: const Icon(Icons.copy)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FoloCard(
              color: Colors.blue,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.userScreenADHD,
                    style: (Theme.of(context).textTheme.headline5 ??
                            const TextStyle())
                        .copyWith(color: ColorTransform.textColor(Colors.blue)),
                  ),
                  const Divider(),
                  Text(
                    UserStorage.adhdType == null
                        ? AppLocalizations.of(context)!
                            .userScreenYouDidntStateWhetherYouHaveADHD
                        : UserStorage.adhdType == ADHDType.adhd
                            ? AppLocalizations.of(context)!
                                .userScreenYouStatedThatYouHaveAnADHDDiagnosis
                            : UserStorage.adhdType ==
                                    ADHDType.noAdhdButFocusProblems
                                ? AppLocalizations.of(context)!
                                    .userScreenYouStatedThatYouDontHaveADHDButFocusProblems
                                : AppLocalizations.of(context)!
                                    .userScreenYouStatedThatYouHaveNeitherADHDNorFocusProblems,
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  FoloButton(
                      child: Text(AppLocalizations.of(context)!.change),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25))),
                                contentPadding: const EdgeInsets.all(12),
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.doYouHaveADHD,
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  FoloButton(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .neitherADHDNorFocusProblems,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      LrsSync.sendADHDType(
                                          ADHDType.noFocusProblems);
                                      setState(() {
                                        UserStorage.adhdType =
                                            ADHDType.noFocusProblems;
                                        Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  FoloButton(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .focusProblemsButNoADHDDiagnosis,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      LrsSync.sendADHDType(
                                          ADHDType.noAdhdButFocusProblems);
                                      setState(() {
                                        UserStorage.adhdType =
                                            ADHDType.noAdhdButFocusProblems;
                                        Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  FoloButton(
                                    height: 100,
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .adhdDiagnosis,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      LrsSync.sendADHDType(ADHDType.adhd);
                                      setState(() {
                                        UserStorage.adhdType = ADHDType.adhd;
                                        Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  FoloButton(
                                      child: Text(
                                          AppLocalizations.of(context)!.cancel),
                                      color: Colors.red,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }),
                                ],
                              );
                            });
                      })
                ],
              ),
            ),
            FoloCard(
              color: Colors.blue,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.userScreenDataCollection,
                    style: (Theme.of(context).textTheme.headline5 ??
                            const TextStyle())
                        .copyWith(color: ColorTransform.textColor(Colors.blue)),
                  ),
                  const Divider(),
                  Text(
                    UserStorage.hasConsent
                        ? AppLocalizations.of(context)!
                            .userScreenYouCurrentlyConsentToDataCollection
                        : AppLocalizations.of(context)!
                            .userScreenYouCurrentlyDontConsentToDataCollection,
                    textAlign: TextAlign.center,
                    style: (Theme.of(context).textTheme.headline5 ??
                            const TextStyle())
                        .copyWith(
                            color: ColorTransform.textColor(
                                UserStorage.hasConsent
                                    ? Colors.green
                                    : Colors.red)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        FoloButton(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(UserStorage.hasConsent
                                  ? AppLocalizations.of(context)!
                                      .userScreenStopSendingData
                                  : AppLocalizations.of(context)!
                                      .userScreenStartSendingData),
                            ),
                            color: UserStorage.hasConsent
                                ? Colors.red
                                : Colors.green,
                            onPressed: () {
                              if (UserStorage.adhdType == null &&
                                  // This expression evaluates to true only if
                                  // The user pressed the button in order to consent
                                  !UserStorage.hasConsent) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25))),
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .doYouHaveADHD,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 40,
                                          ),
                                          FoloButton(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .neitherADHDNorFocusProblems,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                            onPressed: () {
                                              LrsSync.sendADHDType(
                                                  ADHDType.noFocusProblems);
                                              setState(() {
                                                UserStorage.adhdType =
                                                    ADHDType.noFocusProblems;
                                                Navigator.of(context).pop();
                                              });
                                            },
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          FoloButton(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .focusProblemsButNoADHDDiagnosis,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                            onPressed: () {
                                              LrsSync.sendADHDType(ADHDType
                                                  .noAdhdButFocusProblems);
                                              setState(() {
                                                UserStorage.adhdType = ADHDType
                                                    .noAdhdButFocusProblems;
                                                Navigator.of(context).pop();
                                              });
                                            },
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          FoloButton(
                                            height: 100,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .adhdDiagnosis,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                            onPressed: () {
                                              LrsSync.sendADHDType(
                                                  ADHDType.adhd);
                                              setState(() {
                                                UserStorage.adhdType =
                                                    ADHDType.adhd;
                                                Navigator.of(context).pop();
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          FoloButton(
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .cancel),
                                              color: Colors.red,
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                UserStorage.hasConsent = true;
                                              }),
                                        ],
                                      );
                                    });
                              }
                              setState(() {
                                UserStorage.hasConsent =
                                    !UserStorage.hasConsent;
                              });
                            }),
                        const SizedBox(height: 12),
                        Text(AppLocalizations.of(context)!
                            .userScreenYouCanAlwaysRevokeConsent),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(Config.helpEmail),
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
                                              to: [
                                        "focuslocus@librico.mozmail.com"
                                      ],
                                              subject:
                                                  "[FocusLocus] Data Deletion",
                                              body: "Mein Pseudonym is: \"" +
                                                  UserStorage.pseudonym +
                                                  "\"")
                                          .toString())
                                      .onError((error, stackTrace) {
                                    // When the user's operating system does not support opening mailto links
                                    Clipboard.setData(const ClipboardData(
                                        text:
                                            "focoslocus@librico.mozmail.com"));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(AppLocalizations.of(
                                                    context)!
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
