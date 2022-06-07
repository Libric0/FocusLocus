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
import 'package:focuslocus/local_storage/learning_metadata_storage.dart';
import 'package:focuslocus/local_storage/quiz_card_metadata_type.dart';

/// This widget is wrapped around each QuizCardScreen. It notices the user
/// resuming the App and, when done so, increments the QuizCardMetadata
/// numberStarted. When you subtract numberCompleted from numberStarted, you
/// get the number of paused/cancelled attempts. In terms of ADHD research, it
/// means that the user has lost focus.
class QuizCardScreenPauseObserverWrapper extends StatefulWidget {
  final Widget child;
  final String cardType;
  const QuizCardScreenPauseObserverWrapper({
    required this.child,
    required this.cardType,
    Key? key,
  }) : super(key: key);

  @override
  _QuizCardScreenPauseObserverWrapperState createState() =>
      _QuizCardScreenPauseObserverWrapperState();
}

class _QuizCardScreenPauseObserverWrapperState
    extends State<QuizCardScreenPauseObserverWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    incrementNumberStarted();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ignore: unused_field
  late AppLifecycleState _notification;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });

    if (state == AppLifecycleState.resumed) {
      incrementNumberStarted();
    }
    super.didChangeAppLifecycleState(state);
  }

  void incrementNumberStarted() {
    LearningMetadataStorage.increment(
      widget.cardType,
      QuizCardMetadataType.numberStarted,
    );
  }
}
