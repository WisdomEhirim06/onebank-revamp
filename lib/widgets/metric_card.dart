import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).cardColor.withOpacity(0.95),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
    );
  }
}
