// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:focuslocus/config.dart';
import 'package:focuslocus/local_storage/adhd_type.dart';
import 'package:focuslocus/web_communication/lrs_sync.dart';
import 'package:focuslocus/local_storage/user_storage.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The screen that shows a welcome message and asks for consent from the user
class WelcomeScreen extends StatefulWidget {
  final Function closeCallBack;
  const WelcomeScreen({required this.closeCallBack, Key? key})
      : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  PageController pageController = PageController(initialPage: 0);
  List<ScrollController> pageScrollControllers = [
    for (int i = 0; i < 5; i++) ScrollController()
  ];
  PageController hiddenCardController = PageController(
    initialPage: 0,
  );
  bool hasConsentedInWelcomeScreen = false;

  @override
  Widget build(BuildContext context) {
    int listSize = 4;
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: hiddenCardController,
      children: [
        ListView(
          physics: const PageScrollPhysics(),
          scrollDirection: Axis.horizontal,
          controller: pageController,
          children: [
            _WelcomeCard(
              welcomeCardPageController: pageController,
              headline: AppLocalizations.of(context)!.welcomeScreenHi,
              listSize: listSize,
              position: 0,
              controller: pageScrollControllers[0],
              children: [
                const SizedBox(
                  height: 200,
                ),
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenThankYouForDownLoadingFocusLocus,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                )
              ],
            ),
            _WelcomeCard(
              welcomeCardPageController: pageController,
              listSize: listSize,
              headline: AppLocalizations.of(context)!.welcomeScreenTheStudy,
              position: 1,
              controller: pageScrollControllers[1],
              children: [
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenTheAppCanDoMoreThanJustHelpYouStudy,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                const Divider(),
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenThisIsYourPseudonym,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 12, right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 5),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Text(UserStorage.pseudonym),
                ),
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenOnlyYouKnowThatItIsYours,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenYouCanFindItUnderTheMenuEntryUser,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            _WelcomeCard(
              welcomeCardPageController: pageController,
              listSize: listSize,
              position: 2,
              headline: AppLocalizations.of(context)!.welcomeScreenYourData,
              headlineColor: Colors.red,
              controller: pageScrollControllers[2],
              children: [
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenWhatIsSavedUnderYourPseudonym,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.welcomeScreenWhetherYouHaveADHD,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenWhenYouOpenedTheApp,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.welcomeScreenPerCardType,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    AppLocalizations.of(context)!
                        .welcomeScreenHowOftenYouPlayedIt,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    AppLocalizations.of(context)!
                        .welcomeScreenHowManyYouGotRight,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    AppLocalizations.of(context)!
                        .welcomeScreenHowManyYouGotWrong,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    AppLocalizations.of(context)!
                        .welcomeScreenHowManyErrorsOfOmissionOccured,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    AppLocalizations.of(context)!
                        .welcomeScreenHowManyErrorsOfCommissionOccured,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    AppLocalizations.of(context)!
                        .welcomeScreenHowMuchTimeYouSpentOnIt,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    AppLocalizations.of(context)!
                        .welcomeScreenHowOftenItWasDisplayed,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenTheDataIsSavedInPlace(
                          Config.learningRecordStoreName),
                  textAlign: TextAlign.center,
                )
              ],
            ),
            _WelcomeCard(
              welcomeCardPageController: pageController,
              listSize: listSize,
              position: 3,
              headline: AppLocalizations.of(context)!.welcomeScreenConsent,
              controller: pageScrollControllers[3],
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenNowYouKnowEverything,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenMayICollectYourData,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                Text(
                  AppLocalizations.of(context)!
                      .welcomeScreenYouCanViewAndChangeThisUnderTheMenuEntryUser,
                  style:
                      Theme.of(context).textTheme.caption ?? const TextStyle(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 250,
                ),
                FoloButton(
                  child:
                      Text(AppLocalizations.of(context)!.welcomeScreenOfCourse),
                  onPressed: () {
                    UserStorage.hasConsent = true;
                    hiddenCardController.nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.linear);
                  },
                  color: Colors.green,
                ),
                const SizedBox(
                  height: 20,
                ),
                FoloButton(
                  child: Text(
                      AppLocalizations.of(context)!.welcomeScreenNoLetMeStudy),
                  onPressed: () {
                    UserStorage.hasConsent = false;
                    UserStorage.hasSeenWelcomeScreen = true;
                    UserStorage.adhdType = null;
                    widget.closeCallBack();
                  },
                  color: Colors.red,
                )
              ],
            ),
          ],
        ),
        _WelcomeCard(
          listSize: 5,
          position: 4,
          headline: AppLocalizations.of(context)!.welcomeScreenADHDState,
          headlineColor: Colors.green,
          controller: pageScrollControllers[4],
          children: [
            Text(
              AppLocalizations.of(context)!.welcomeScreenThanks,
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              AppLocalizations.of(context)!.welcomeScreenNowYouJustHaveToTellMe,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            Text(
              AppLocalizations.of(context)!.doYouHaveADHD,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 40,
            ),
            FoloButton(
              height: 100,
              child: Text(
                AppLocalizations.of(context)!.neitherADHDNorFocusProblems,
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                UserStorage.hasSeenWelcomeScreen = true;
                UserStorage.adhdType = ADHDType.noFocusProblems;
                LrsSync.sendADHDType(ADHDType.noFocusProblems);

                widget.closeCallBack();
              },
            ),
            const SizedBox(
              height: 10,
            ),
            FoloButton(
              height: 100,
              child: Text(
                AppLocalizations.of(context)!.focusProblemsButNoADHDDiagnosis,
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                UserStorage.hasSeenWelcomeScreen = true;
                UserStorage.adhdType = ADHDType.noAdhdButFocusProblems;
                LrsSync.sendADHDType(ADHDType.noAdhdButFocusProblems);
                widget.closeCallBack();
              },
            ),
            const SizedBox(
              height: 10,
            ),
            FoloButton(
              height: 100,
              child: Text(
                AppLocalizations.of(context)!.adhdDiagnosis,
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                UserStorage.hasSeenWelcomeScreen = true;
                UserStorage.adhdType = ADHDType.adhd;
                LrsSync.sendADHDType(ADHDType.adhd);

                widget.closeCallBack();
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// A card on the welcome screen.
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    Key? key,
    required this.listSize,
    required this.position,
    required this.headline,
    required this.children,
    required this.controller,
    this.welcomeCardPageController,
    this.headlineColor = Colors.blue,
  }) : super(key: key);

  final int listSize;
  final int position;
  final String headline;
  final List<Widget> children;
  final Color headlineColor;
  final ScrollController controller;
  final PageController? welcomeCardPageController;
  @override
  Widget build(BuildContext context) {
    return FoloCard(
      color: Colors.blue,
      child: Stack(
        children: [
          ListView(
            controller: controller,
            children: [
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: headlineColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Text(
                  headline, //"Die Studie",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.white),
                ),
              ),
              ...children
            ],
          ),
          if (welcomeCardPageController != null)
            Positioned(
              bottom: 0,
              //left: MediaQuery.of(context).size.width / 4 - 60,
              width: MediaQuery.of(context).size.width - 38,
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: DotsIndicator(
                    dotsCount: listSize,
                    position: position.toDouble(),
                    onTap: (index) {
                      welcomeCardPageController!.animateToPage(index.toInt(),
                          curve: Curves.linear,
                          duration: const Duration(milliseconds: 200));
                    },
                  ),
                ),
              ),
            )
        ],
      ),
      width: MediaQuery.of(context).size.width - 24,
    );
  }
}
