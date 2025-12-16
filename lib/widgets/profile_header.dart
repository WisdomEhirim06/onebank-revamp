import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.15),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          // PROFILE INITIAL CIRCLE
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              name[0],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 18),

          // TEXTS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall!.color!.withOpacity(0.7),
                  ),
                ),
                Text(
                  phone,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall!.color!.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
