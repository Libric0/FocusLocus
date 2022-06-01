import 'package:flutter/material.dart';
import 'package:focuslocus/util/color_transform.dart';

/// The app-bar for the deck screen. Was included for the purpose of smoothly
/// changing its color when scrolling through the course overview.
class DeckScreenTopBar extends StatefulWidget {
  final Color deckColor;
  final String courseName;
  const DeckScreenTopBar(
      {required this.deckColor, required this.courseName, Key? key})
      : super(key: key);

  @override
  State<DeckScreenTopBar> createState() => _DeckScreenTopBarState();
}

class _DeckScreenTopBarState extends State<DeckScreenTopBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          width: double.infinity,
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(
                  Icons.menu_rounded,
                  color: widget.deckColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.courseName,
                style: Theme.of(context).textTheme.headline6 != null
                    ? Theme.of(context).textTheme.headline6?.copyWith(
                          color: ColorTransform.textColor(widget.deckColor),
                          overflow: TextOverflow.ellipsis,
                        )
                    : TextStyle(
                        color: ColorTransform.textColor(widget.deckColor),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.deckColor,
                ColorTransform.scaffoldBackgroundColor(widget.deckColor),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
