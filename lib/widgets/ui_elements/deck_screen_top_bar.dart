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
