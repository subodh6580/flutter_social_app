import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foap/components/custom_texts.dart';

class UnlockTimerView extends StatefulWidget {
  final int unlockTime; // Time in seconds to unlock the lesson
  final VoidCallback completionHandler;
  const UnlockTimerView({Key? key, required this.unlockTime,required this.completionHandler}) : super(key: key);

  @override
  UnlockTimerViewState createState() => UnlockTimerViewState();
}

class UnlockTimerViewState extends State<UnlockTimerView> {
  late Timer _timer;
  int _remainingTime = 0;

  @override
  void initState() {
    _remainingTime = widget.unlockTime;
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant UnlockTimerView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // print('_remainingTime $_remainingTime');
        if (_remainingTime <= 0) {
          timer.cancel();
          widget.completionHandler();
        } else {
          _remainingTime--;
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {

    return BodyLargeText(
      _formatTime(_remainingTime),
      color: Colors.white,
    );
  }
}
