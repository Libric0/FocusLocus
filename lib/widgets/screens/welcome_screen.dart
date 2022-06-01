import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:focuslocus/local_storage/adhd_type.dart';
import 'package:focuslocus/web_communication/lrs_sync.dart';
import 'package:focuslocus/local_storage/user_storage.dart';
import 'package:focuslocus/widgets/ui_elements/folo_button.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';

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
              headline: "Hi!",
              listSize: listSize,
              position: 0,
              controller: pageScrollControllers[0],
              children: [
                const SizedBox(
                  height: 200,
                ),
                Text(
                  "Danke, dass du FocusLocus gedownloaded hast!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                )
              ],
            ),
            _WelcomeCard(
              welcomeCardPageController: pageController,
              listSize: listSize,
              headline: "Die Studie",
              position: 1,
              controller: pageScrollControllers[1],
              children: [
                Text(
                  "Die App kann aber mehr als Dir bei BuK helfen: Ich habe sie programmiert, um herauszufinden, ob und wie Menschen mit ADHS anders lernen als Andere. Dafür würde ich gerne anonymisierte Daten sammeln",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                const Divider(),
                Text(
                  "Das ist dein Pseudonym",
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
                  "Nur du weißt, dass es deins ist",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Ist in dem Menüpunkt \"Nutzer\" auffindbar",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            _WelcomeCard(
              welcomeCardPageController: pageController,
              listSize: listSize,
              position: 2,
              headline: "Deine Daten",
              headlineColor: Colors.red,
              controller: pageScrollControllers[2],
              children: [
                const Text(
                  "Was unter deinem Pseudonym gespeichert wird",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
                Text(
                  "- Ob du ADHS hast",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                const SizedBox(height: 20),
                Text(
                  "- Pro Kartentyp",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    "- Wie oft du sie gespielt hast",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    "- Wie viele du richtig hast",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    "- Wie viele du falsch hast",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    "- Wie viele Omissionsfehler du hast",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    "- Wie viele Commissionsfehler du hast",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    "- Wie lange du daran saßt (Sekunden)",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    "- Wie oft du sie dir Anzeigen lassen hast",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6 ??
                        const TextStyle(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Gespeichert werden sie im Learning Record Store des i9",
                  textAlign: TextAlign.center,
                )
              ],
            ),
            _WelcomeCard(
              welcomeCardPageController: pageController,
              listSize: listSize,
              position: 3,
              headline: "Zustimmung",
              controller: pageScrollControllers[3],
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Jetzt weisst du alles.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Darf ich deine Daten Sammeln?",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5 ??
                      const TextStyle(),
                ),
                Text(
                  "Du kannst die Zustimmung immer unter dem Menüpunkt \"Nutzer\" einsehen und via eMail ändern",
                  style:
                      Theme.of(context).textTheme.caption ?? const TextStyle(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 250,
                ),
                FoloButton(
                  child: const Text("Ja, klar!"),
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
                  child: const Text("Nein, lass mich lernen!"),
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
          headline: "ADHS-Zustand",
          headlineColor: Colors.green,
          controller: pageScrollControllers[4],
          children: [
            Text(
              "Danke!",
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Jetzt muss ich nur noch wissen:",
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            Text(
              "Hast du ADHS?",
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 40,
            ),
            FoloButton(
              height: 100,
              child: const Text(
                "Weder ADHS noch Konzentrationsprobleme",
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
              child: const Text(
                "Kozentrationsprobleme, aber keine ADHS Diagnose",
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
              child: const Text(
                "ADHS Diagnose",
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
