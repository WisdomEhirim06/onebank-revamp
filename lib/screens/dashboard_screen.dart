import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/quick_action.dart';
import '../widgets/transaction_tile.dart';
import 'transfer_recipient_screen.dart';
import 'transaction_history_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import '../services/user_session.dart';
import '../services/transaction_cache.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;

  String _formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(2);
    // Add commas using Regex
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) mathFunc = (Match match) => '${match[1]},';
    return '₦${amountStr.replaceAllMapped(reg, mathFunc)}';
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to Analytics Screen
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
      ).then((_) {
        // Reset nav highlight back to Home when returning
        setState(() => _selectedIndex = 0);
      });
    }
    
    // Navigate to Profile Screen
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      ).then((_) {
        // Reset nav highlight back to Home when returning
        setState(() => _selectedIndex = 0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch account and transactions from cache
    final account = TransactionCache().account;
    final allTransactions = TransactionCache().transactions;
    final recentTransactions = allTransactions.take(5).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF5F6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome back,',
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xFF757575))),
                            const SizedBox(height: 4),
                            Text(UserSession().currentUser?.fullName ?? 'User',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFED1B2E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFED1B2E), Color(0xFFB8132A)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFED1B2E).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Available Balance',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14)),
                                    Icon(Icons.visibility_outlined,
                                        color: Colors.white70, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  account != null
                                      ? _formatCurrency(account.balance)
                                      : '₦0.00',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text('Account: ',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                    Text(account?.accountNumber ?? 'XXXX XXXX XXXX',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              QuickAction(
                                  icon: Icons.swap_horiz,
                                  label: 'Transfer',
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        createRoute(
                                            const TransferRecipientScreen()));
                                  }),
                              QuickAction(
                                  icon: Icons.receipt_long,
                                  label: 'Pay Bills',
                                  onTap: () {}),
                              QuickAction(
                                  icon: Icons.phone_android,
                                  label: 'Airtime',
                                  onTap: () {}),
                              QuickAction(
                                  icon: Icons.credit_card,
                                  label: 'Cards',
                                  onTap: () {}),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Recent Transactions',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => TransactionHistoryScreen()),
                                  );
                                },
                                child: const Text('See all',
                                    style: TextStyle(
                                        color: Color(0xFFED1B2E),
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dynamic transaction List
                          if (recentTransactions.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: Text(
                                  "No recent transactions",
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            )
                          else
                            ...recentTransactions.map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: TransactionTile(
                                title: t.title,
                                bank: t.bank,
                                accountNumber: t.accountNumber,
                                senderName: t.senderName,
                                recipientName: t.recipientName,
                                amount: t.amount,
                                isCredit: t.isCredit,
                                timestamp: t.timestamp,
                                description: t.description,
                                txnRef: t.txnRef,
                              ),
                            )),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavIcon(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: _selectedIndex == 0,
                onTap: () => _onNavTap(0),
              ),
              _NavIcon(
                icon: Icons.pie_chart_rounded,
                label: 'Analytics',
                isActive: _selectedIndex == 1,
                onTap: () => _onNavTap(1),
                
              ),
              _NavIcon(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Loans',
                isActive: _selectedIndex == 2,
                onTap: () => _onNavTap(2),
              ),
              _NavIcon(
                icon: Icons.person_rounded,
                label: 'Me',
                isActive: _selectedIndex == 3,
                onTap: () => _onNavTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFEEF0) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFED1B2E).withOpacity(0.35),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSlide(
              offset: isActive ? const Offset(0, -0.15) : Offset.zero,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: 28,
                color: isActive
                    ? const Color(0xFFED1B2E)
                    : const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFFED1B2E)
                    : const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}