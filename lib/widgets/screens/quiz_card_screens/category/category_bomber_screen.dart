import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focuslocus/knowledge/knowledge_category.dart';
import 'package:focuslocus/util/color_transform.dart';
import 'package:focuslocus/util/style_constants.dart';
import 'package:focuslocus/widgets/quiz_card_items/quiz_card_help_dialog.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/correction_wrapper.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/quiz_card_screen.dart';
import 'package:focuslocus/widgets/screens/quiz_card_screens/wrappers/quiz_card_screen_pause_observer_wrapper.dart';
import 'package:focuslocus/widgets/quiz_card_items/tex_text.dart';
import 'package:focuslocus/widgets/ui_elements/folo_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A quizCardScreen that organizes items of the universe in a 3x3 grid. The
/// correct items alwas form a + shape within this grid. For example, this would
/// be a valid grid, where X represents the items that are supposed to be
/// 'destroyed'
/// - [] [] X
/// - [] X  X
/// - [] [] X
///
/// The Typical assignment here would be: "Only leave [] unharmed". It may be
/// interesting to also say: "Destroy all X", due to focus and commission errors.
class CategoryBomberScreen extends QuizCardScreen {
  final List<KnowledgeCategory> categories;
  const CategoryBomberScreen({
    required this.categories,
    required void Function({
      int errors,
      int commissionErrors,
      int omissionErrors,
      required int playtime,
      bool easy,
    })
        onComplete,
    required Color color,
    Key? key,
  }) : super(
            knowledge: categories,
            cardType: "category_bomber",
            onComplete: onComplete,
            color: color,
            key: key);

  @override
  _CategoryBomberScreenState createState() => _CategoryBomberScreenState();

  /// The Help dialog of this card type
  @override
  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => QuizCardHelpDialog(
        children: [
          FoloCard(
            child: Text(
              AppLocalizations.of(context)!
                  .categoryBomberHelpDialogPlaceABombToBlowUp,
              textAlign: TextAlign.center,
              style:
                  (Theme.of(context).textTheme.headline6 ?? const TextStyle())
                      .copyWith(
                color: ColorTransform.textColor(color),
              ),
            ),
            color: color,
          ),
          FoloCard(
            color: color,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!
                      .categoryBomberHelpDialogPlusShapedExplosionDestroysFive),
                  Image.asset(
                      "assets/help_dialogs/category_bomber_screen_explosion.png")
                ],
              ),
            ),
          ),
          FoloCard(
            color: color,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!
                      .categoryBomberHelpDialogGeodesThatWereBlownUpCorrectly),
                  Image.asset(
                      "assets/help_dialogs/category_bomber_screen_remains.png")
                ],
              ),
            ),
          ),
          FoloCard(
            color: color,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!
                      .categorybomberHelpDialogYouDidEverythingCorrectlyIf),
                  Image.asset(
                      "assets/help_dialogs/category_bomber_screen_correct.png")
                ],
              ),
            ),
          )
        ],
        color: color,
      ),
    );
  }
}

class _CategoryBomberScreenState extends State<CategoryBomberScreen> {
  bool firstBuild = true;
  bool revealed = false;
  bool animationShouldContinue = false;
  int playtime = 0;
  // ignore: unused_field
  late Timer _timer;
  late Random _random;
  int commissionErrors = 0, omissionErrors = 0;
  int explosionX = 0, explosionY = 0;
  bool exploding = false;

  List<List<bool>> destroyed = [
    [false, false, false],
    [false, false, false],
    [false, false, false]
  ];
  late Point<int> correctPosition;
  late List<List<String>> chosenItems;

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      _random = Random(DateTime.now().hashCode);
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        playtime++;
      });

      // randomly drawing the correct
      correctPosition = Point<int>(_random.nextInt(3), _random.nextInt(3));
      chosenItems = chooseItems(widget.categories[0], correctPosition, _random);
      firstBuild = false;
    }
    return QuizCardScreenPauseObserverWrapper(
      cardType: widget.cardType,
      child: CorrectionWrapper(
        quizCardID: widget.knowledge[0].id,
        playtime: playtime,
        commissionErrors: commissionErrors,
        omissionErrors: omissionErrors,
        errors: commissionErrors + omissionErrors,
        incorrectMessage: omissionErrors > 0 && commissionErrors == 0
            ? AppLocalizations.of(context)!.categoryBomberNotEnough
            : commissionErrors > 0 && omissionErrors == 0
                ? AppLocalizations.of(context)!.categoryBomberTooMany
                : AppLocalizations.of(context)!.categoryBomberSomethingIsWrong,
        onComplete: widget.onComplete,
        revealed: revealed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FoloCard(
              color: widget.color,
              child: TexText(
                style: TextStyle(color: widget.color),
                rawString: AppLocalizations.of(context)!
                    .categoryBomberStandardQuestion(
                        widget.categories[0].categoryNamesPlural[0]),
              ),
            ),
            Stack(
              children: [
                CategoryBomberGrid(
                  correctPosition: correctPosition,
                  chosenItems: chosenItems,
                  destroyed: destroyed,
                  canBomb: !revealed,
                  onBomb: (x, y) {
                    setState(() {
                      exploding = true;
                      explosionX = x;
                      explosionY = y;
                      for (int xx = 0; xx < 3; xx++) {
                        for (int yy = 0; yy < 3; yy++) {
                          if ((x - xx).abs() + (y - yy).abs() <= 1) {
                            destroyed[xx][yy] = true;
                          }
                        }
                      }
                      correct();
                      revealed = true;
                    });
                  },
                ),

                /// The explosion is always on top of the category bomber grid,
                /// but will only be revealed once an item has been tapped
                Expliosion(exploding: exploding, x: explosionX, y: explosionY)
              ],
            ),
            const SizedBox(
              height: 140,
            )
          ],
        ),
      ),
    );
  }

  /// The method that looks whether the user chose the correct position.
  /// If not, it counts the errors of omission and commission
  void correct() {
    // creating a grid showing which items are correct
    List<List<bool>> correctGrid = [
      for (int x = 0; x < 3; x++)
        [
          for (int y = 0; y < 3; y++)
            (x - correctPosition.x).abs() + (y - correctPosition.y).abs() <= 1
        ]
    ];
    // counting errors based on the created grid and the destroyed items
    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        if (destroyed[x][y] != correctGrid[x][y]) {
          if (destroyed[x][y]) {
            commissionErrors++;
          } else {
            omissionErrors++;
          }
        }
      }
    }
  }

  /// Returns a list of rawStrings for mathobjects in a 3x3 grid. The mathobjects
  /// are contained in the category if and only if the grid position has a distance
  /// of one (not diagonal) to the correctPosition
  List<List<String>> chooseItems(
      KnowledgeCategory category, Point<int> correctPosition, Random random) {
    // Constructing the correct grid. An item in that grid is true, if it is at
    // most one step (not diagonal) away
    List<List<bool>> correctGrid = [
      for (int x = 0; x < 3; x++)
        [
          for (int y = 0; y < 3; y++)
            ((correctPosition.x - x).abs() + (correctPosition.y - y).abs()) <= 1
        ]
    ];

    // Pick a random mathobject-rawString for each x,y, which is in the category
    // if and only if correctGrid[x][y] is true
    return [
      for (int x = 0; x < 3; x++)
        [
          for (int y = 0; y < 3; y++)
            correctGrid[x][y]
                ? category.universe.texTextRawStringAt(
                    (category.indicesInCategory[
                        random.nextInt(category.indicesInCategory.length)]))
                : category.universe.texTextRawStringAt(
                    category.indicesNotInCategory[
                        random.nextInt(category.indicesNotInCategory.length)])
        ]
    ];
  }
}

/// The grid belonging to the CategoryBomberScreen.
class CategoryBomberGrid extends StatelessWidget {
  final bool canBomb;
  final Point<int> correctPosition;
  final List<List<String>> chosenItems;
  final Function(int x, int y) onBomb;
  final List<List<bool>> destroyed;
  const CategoryBomberGrid(
      {required this.chosenItems,
      required this.destroyed,
      required this.correctPosition,
      required this.onBomb,
      required this.canBomb,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.brown[200],
          boxShadow: const [StyleConstants.cardBoxShadow],
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          border: Border.all(
            width: 5.0,
            color: Colors.brown[300] ?? Colors.white,
          ),
        ),
        // The actual grid: A row+column (3x3) containing explodable math rocks
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int x = 0; x < 3; x++)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int y = 0; y < 3; y++)
                    ExplodableMathRock(
                        correct: (correctPosition.x - x).abs() +
                                (correctPosition.y - y).abs() <=
                            1,
                        canBomb: canBomb,
                        onBomb: (x, y) {
                          onBomb(x, y);
                        },
                        x: x,
                        y: y,
                        chosenItems: chosenItems,
                        destroyed: destroyed[x][y]),
                ],
              )
          ],
        ),
      ),
    );
  }
}

/// The geodes that contain Math items and can explode
class ExplodableMathRock extends StatefulWidget {
  const ExplodableMathRock({
    Key? key,
    required this.correct,
    required this.canBomb,
    required this.onBomb,
    required this.x,
    required this.y,
    required this.chosenItems,
    required this.destroyed,
  }) : super(key: key);

  final bool correct;

  /// Whether the quiz card is still active. This is false, if
  /// an explosion already took place
  final bool canBomb;

  /// The function that is called when a bomb is dropped. It should contain rules
  /// when a rock should be destroyed. Future versions may have bigger or smaller
  /// bombs (or other variations) and therefore it needs to be implemented in the
  /// upper widgets
  final Function(int x, int y) onBomb;

  /// The x position of this rock
  final int x;

  /// The y position of this rock
  final int y;

  /// The list of all chosen items
  final List<List<String>> chosenItems;

  /// Whether this rock is displayed as destroyed
  final bool destroyed;

  @override
  State<ExplodableMathRock> createState() => _ExplodableMathRockState();
}

class _ExplodableMathRockState extends State<ExplodableMathRock> {
  int frame = -1;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.canBomb) {
          widget.onBomb(widget.x, widget.y);
          setState(() {
            frame = 10;
          });
        }
      },
      // The appearance of the rock
      child: Container(
        width: 90,
        height: 90,
        margin: const EdgeInsets.all(12),
        child: Stack(
          children: [
            // shadow of the rock
            PhysicalModel(
              child: Transform.scale(
                scale: widget.destroyed ? 1.2 : 1,
                child: SvgPicture.asset(
                  !widget.destroyed
                      ? "assets/textures/stone_intact.svg"
                      : widget.correct
                          ? "assets/textures/goldOre.svg"
                          : "assets/textures/debree.svg",
                  fit: BoxFit.fill,
                ),
              ),
              color: Colors.transparent,
              shape: BoxShape.circle,
              elevation: 5,
              shadowColor:
                  !widget.destroyed ? Colors.black : Colors.transparent,
            ),
            Center(
              child: FittedBox(
                child: Container(
                  // if the widget is destroyed and correct, the gold ore
                  // svg will be evened out around the text to impove visual
                  // clarity
                  decoration: widget.destroyed && !widget.correct
                      ? BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Colors.brown[200] ?? Colors.white,
                              blurRadius: 2)
                        ])
                      : null,
                  // The displayed text. Brown if the rock is destroyed and
                  // contans gold, white otherwise
                  child: TexText(
                    rawString: widget.chosenItems[widget.x][widget.y],
                    style: TextStyle(
                      color: widget.destroyed && widget.correct
                          ? Colors.brown
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The explosion that is triggered by tapping an explodable math rock. It
/// is animated. The animation starts once the boolean [exploding] is set to true
class Expliosion extends StatefulWidget {
  final bool exploding;
  final int x;
  final int y;
  const Expliosion(
      {required this.exploding, required this.x, required this.y, Key? key})
      : super(key: key);

  @override
  _ExpliosionState createState() => _ExpliosionState();
}

class _ExpliosionState extends State<Expliosion> {
  bool visible = true;
  int frame = -1;
  @override
  Widget build(BuildContext context) {
    frame = widget.exploding ? 10 : -1;
    return Transform.translate(
      offset: Offset(-45.0 + 114.0 * widget.x, -45.0 + 114.0 * widget.y),
      child: Transform.scale(
        scale: 2,
        // as long as it is invisible, it does not block interaction with widgets
        // below
        child: Visibility(
          visible: frame != -1 && visible,
          // As flutter has no explicit SVG-Video widget, it was created by
          // animating the frame number using a tweenanimation builder
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 500),
            tween: Tween<double>(begin: 0, end: frame.toDouble()),
            builder: (context, double tweenFrame, _) {
              int actualFrame = tweenFrame >= 0 ? tweenFrame.round() : 0;
              return SvgPicture.asset(
                  "assets/textures/cornerExplosion$actualFrame.svg");
            },
            onEnd: () {
              setState(() {
                frame = -1;
                visible = false;
              });
            },
          ),
        ),
      ),
    );
  }
}
