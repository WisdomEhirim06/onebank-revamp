import 'package:flutter/material.dart';
import 'dart:ui';
import '../main.dart';
import 'dashboard_screen.dart';
import 'receipt_screen.dart';

class TransferSuccessScreen extends StatefulWidget {
  final String senderName;
  final String recipientName;
  final String accountNumber;
  final String bank;
  final double amount;
  final String description;
  final String txnRef;
  final DateTime timestamp;
  final bool isInterAccount;

  const TransferSuccessScreen({
    Key? key,
    required this.senderName,
    required this.recipientName,
    required this.accountNumber,
    required this.bank,
    required this.amount,
    required this.description,
    required this.txnRef,
    required this.timestamp,
    this.isInterAccount = false,
  }) : super(key: key);

  @override
  State<TransferSuccessScreen> createState() => _TransferSuccessScreenState();
}

class _TransferSuccessScreenState extends State<TransferSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Initialize Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _viewReceipt() {
    Navigator.push(
      context,
      createRoute(ReceiptScreen(
        senderName: widget.senderName,
        recipientName: widget.recipientName,
        accountNumber: widget.accountNumber,
        bank: widget.bank,
        amount: widget.amount,
        description: widget.description,
        txnRef: widget.txnRef,
        timestamp: widget.timestamp,
      )),
    );
  }

  void _goToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      createRoute(const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF5F6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),

                            // Animated Checkmark Icon (Red Gradient Style)
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFED1B2E), Color(0xFFB8132A)],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFED1B2E).withOpacity(0.18),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 60),
                              ),
                            ),

                            const SizedBox(height: 22),

                            const Text(
                              'Transfer Successful',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              '₦${widget.amount.toStringAsFixed(2)} sent to ${widget.recipientName}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF757575)),
                            ),

                            // Logic: Show blue badge if inter-account
                            if (widget.isInterAccount)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        color: Colors.blue.shade700, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Credited to OneBank account',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Stylish Receipt Card (Passing Real Data)
                            _StylishReceiptCard(
                              senderName: widget.senderName,
                              recipientName: widget.recipientName,
                              accountNumber: widget.accountNumber,
                              bank: widget.bank,
                              amount: widget.amount,
                              description: widget.description,
                              txnRef: widget.txnRef,
                              timestamp: widget.timestamp,
                            ),

                            // Flexible spacer to push buttons to bottom
                            const Expanded(child: SizedBox(height: 20)),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _viewReceipt,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFFED1B2E)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('View Receipt',
                                        style: TextStyle(color: Color(0xFFED1B2E))),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _goToDashboard,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFED1B2E),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Done',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// --- STYLISH CARD WIDGET ---
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
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ];
    return days[i - 1];
  }

  String _month(int i) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
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
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          // Header with Glassmorphism
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Stack(
              children: [
                Container(
                  height: 120, // Reduced slightly for better mobile fit
                  width: double.infinity,
                  decoration: const BoxDecoration(
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
                    height: 120,
                    alignment: Alignment.center,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                _receiptRow("Transaction ID", txnRef),
                _receiptRow("Sender", senderName),
                _receiptRow("Recipient", recipientName),
                _receiptRow("Bank", bank),
                _receiptRow("Account Number", accountNumber),
                _receiptRow("Amount", "₦${amount.toStringAsFixed(2)}",
                    valueStyle: const TextStyle(
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
          const SizedBox(height: 22),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
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
                  const TextStyle(
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