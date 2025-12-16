import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    double strength = 0;
    if (password.length >= 8) strength += 0.33;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.33;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.34;

    String label = strength < 0.4
        ? 'Weak'
        : strength < 0.7
            ? 'Medium'
            : 'Strong';
    Color color = strength < 0.4
        ? Colors.red
        : strength < 0.7
            ? Colors.orange
            : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  widthFactor: strength,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (password.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Password strength: $label',
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}