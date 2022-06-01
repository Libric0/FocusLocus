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
    WidgetsBinding.instance!.addObserver(this);
    incrementNumberStarted();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
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
