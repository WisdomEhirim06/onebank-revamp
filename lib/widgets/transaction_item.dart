import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isCredit;

  const TransactionItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    this.isCredit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color:
                  isCredit ? const Color(0xFF4CAF50) : const Color(0xFFED1B2E),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1C)),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  isCredit ? const Color(0xFF4CAF50) : const Color(0xFF1C1C1C),
            ),
          ),
        ],
      ),
    );
  }
}