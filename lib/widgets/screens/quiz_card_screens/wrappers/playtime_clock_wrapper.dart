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
