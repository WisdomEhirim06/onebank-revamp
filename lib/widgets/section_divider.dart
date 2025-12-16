import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  final String title;

  const SectionDivider({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary.withOpacity(0.8),
      ),
    );
  }
}
