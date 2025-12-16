import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  const AnimatedProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      color: const Color(0xFFF0F0F0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: MediaQuery.of(context).size.width * progress,
        decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xFFED1B2E), Color(0xFFB8132A)]),
        ),
      ),
    );
  }
}