import 'package:flutter/material.dart';
import '../screens/receipt_screen.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final String bank;
  final String accountNumber;
  final String senderName;
  final String recipientName;
  final double amount;
  final bool isCredit;
  final DateTime timestamp;
  final String description;
  final String txnRef;

  const TransactionTile({
    Key? key,
    required this.title,
    required this.bank,
    required this.accountNumber,
    required this.senderName,
    required this.recipientName,
    required this.amount,
    required this.isCredit,
    required this.timestamp,
    required this.description,
    required this.txnRef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to receipt screen with transaction details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(
              senderName: senderName,
              recipientName: recipientName,
              accountNumber: accountNumber,
              bank: bank,
              amount: amount,
              description: description,
              txnRef: txnRef,
              timestamp: timestamp,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCredit
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$bank • ${_formatTime(timestamp)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}₦${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}