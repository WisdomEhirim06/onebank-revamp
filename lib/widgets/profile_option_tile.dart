import 'package:flutter/material.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? Colors.red
        : theme.textTheme.bodyLarge!.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
