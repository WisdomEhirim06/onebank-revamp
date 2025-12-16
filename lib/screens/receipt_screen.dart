import 'package:flutter/material.dart';
import 'dart:ui';

class ReceiptScreen extends StatelessWidget {
  final String senderName;
  final String recipientName;
  final String accountNumber;
  final String bank;
  final double amount;
  final String description;
  final String txnRef;
  final DateTime timestamp;

  const ReceiptScreen({
    Key? key,
    required this.senderName,
    required this.recipientName,
    required this.accountNumber,
    required this.bank,
    required this.amount,
    required this.description,
    required this.txnRef,
    required this.timestamp,
  }) : super(key: key);

  String getFormattedDate(DateTime time) {
    return "${_formatTime(time)} — ${_weekday(time.weekday)}, "
        "${time.day} ${_month(time.month)} ${time.year}";
  }

  String _weekday(int i) {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    return days[i - 1];
  }

  String _month(int i) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[i - 1];
  }

  String _formatTime(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final ampm = t.hour >= 12 ? "PM" : "AM";
    final minute = t.minute.toString().padLeft(2, '0');
    return "$hour:$minute $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Receipt"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _StylishReceiptCard(
                      senderName: senderName,
                      recipientName: recipientName,
                      accountNumber: accountNumber,
                      bank: bank,
                      amount: amount,
                      description: description,
                      txnRef: txnRef,
                      timestamp: timestamp,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Receipt downloaded (mock).")),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text("Download"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Share sheet opened (mock).")),
                              );
                            },
                            icon: const Icon(Icons.share),
                            label: const Text("Share"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE50914),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // flexible spacer so footer sits on bottom when there's room
                    const Expanded(child: SizedBox()),

                    Column(
                      children: [
                        Text(
                          "If you notice any errors or unauthorized activity, "
                          "please contact Sterling Bank immediately.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Sterling Bank Head Office\n"
                          "Sterling Towers, 20 Marina, Lagos Island, Lagos State, Nigeria\n"
                          "+234 (01) 888 8822\n"
                          "customercare@sterling.ng",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.4,
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Keep _StylishReceiptCard unchanged (you can keep the implementation you already have).


class _StylishReceiptCard extends StatelessWidget {
  final String senderName;
  final String recipientName;
  final String accountNumber;
  final String bank;
  final double amount;
  final String description;
  final String txnRef;
  final DateTime timestamp;

  const _StylishReceiptCard({
    Key? key,
    required this.senderName,
    required this.recipientName,
    required this.accountNumber,
    required this.bank,
    required this.amount,
    required this.description,
    required this.txnRef,
    required this.timestamp,
  }) : super(key: key);

  String getFormattedDate(DateTime time) {
    return "${_formatTime(time)} — ${_weekday(time.weekday)}, "
        "${time.day} ${_month(time.month)} ${time.year}";
  }

  String _weekday(int i) {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    return days[i - 1];
  }

  String _month(int i) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[i - 1];
  }

  String _formatTime(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final ampm = t.hour >= 12 ? "PM" : "AM";
    final minute = t.minute.toString().padLeft(2, '0');
    return "$hour:$minute $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            child: Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE50914), Color(0xFF8A0010)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                  child: Container(
                    height: 140,
                    alignment: Alignment.center,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "OneBank",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Transaction Receipt",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                _receiptRow("Transaction ID", txnRef),
                _receiptRow("Sender", senderName),
                _receiptRow("Recipient", recipientName),
                _receiptRow("Bank", bank),
                _receiptRow("Account Number", accountNumber),
                _receiptRow("Amount", "₦${amount.toStringAsFixed(2)}",
                    valueStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE50914),
                    )),
                _receiptRow(
                    "Description", description.isEmpty ? "-" : description),
                _receiptRow("Date", getFormattedDate(timestamp)),
              ],
            ),
          ),
          SizedBox(height: 22),
          Divider(height: 0, color: Colors.grey.withOpacity(0.18)),
          SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueStyle ??
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}