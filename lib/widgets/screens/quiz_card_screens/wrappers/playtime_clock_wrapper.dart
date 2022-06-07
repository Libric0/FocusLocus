// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';

import 'package:flutter/material.dart';

/// A wrapper-widget that is used to increase the playtime variable for each
/// QuizCardScreen widget. It can also do other routines once a second.
class PlaytimeClockWrapper extends StatefulWidget {
  /// The routine that is called once a second. It should at least contain
  /// playtime++;
  final void Function() routine;

  /// The child of this widget. It may be another functional wrapper, or
  /// UI elements for the
  final Widget child;
  const PlaytimeClockWrapper({
    required this.routine,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _PlaytimeClockWrapperState createState() => _PlaytimeClockWrapperState();
}

class _PlaytimeClockWrapperState extends State<PlaytimeClockWrapper> {
  bool firstBuild = true;
  // ignore: unused_field
  Timer _timer = Timer.periodic(const Duration(seconds: 20), (timer) {});

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          widget.routine();
        },
      );
    }
    return widget.child;
  }
}
