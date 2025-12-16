import 'package:flutter/material.dart';
import 'dart:async';

class ResendTimer extends StatefulWidget {
  const ResendTimer({super.key});

  @override
  State<ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<ResendTimer> {
  int seconds = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return seconds > 0
        ? Text(
            'Resend code in $seconds seconds',
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
          )
        : GestureDetector(
            onTap: () => setState(() {
              seconds = 60;
              startTimer();
            }),
            child: const Text(
              'Resend code',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFED1B2E),
                  fontWeight: FontWeight.w600),
            ),
          );
  }
}