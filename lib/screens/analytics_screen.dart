import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import '../services/transaction_cache.dart';
import '../widgets/trend_chart.dart';
import '../widgets/insight_card.dart';
import '../widgets/income_expense_ratio.dart';
import 'transaction_history_screen.dart';

class DailyTransactionPoint {
  final DateTime date;
  final double amount;

  DailyTransactionPoint({
    required this.date,
    required this.amount,
  });
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final TransactionService _transactionService = TransactionService();
  final TransactionCache _cache = TransactionCache();

  // Analytics data
  List<DailyTransactionPoint> monthlyTrend = [];
  double totalIncome = 0;
  double totalExpenses = 0;
  double highestTransaction = 0;
  String topVendor = "—";
  double avgDailySpending = 0;
  String mostSpentDay = "—";
  bool isLoading = true;

  DateTimeRange? selectedRange;

  String getRangeLabel() {
    if (selectedRange == null) {
      return "This Month";
    }

    final start = DateFormat("MMM d").format(selectedRange!.start);
    final end = DateFormat("MMM d").format(selectedRange!.end);
    return "$start - $end";
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => isLoading = true);

    // Ensure transactions are loaded
    await _transactionService.getTransactions();

    // Calculate analytics
    _calculateAnalytics();

    setState(() => isLoading = false);
    _controller.forward();
  }

  void _calculateAnalytics() {
    final start = selectedRange?.start;
    final end = selectedRange?.end;

    // Get analytics from cache
    totalIncome = _cache.getTotalIncome(start, end);
    totalExpenses = _cache.getTotalExpenses(start, end);
    highestTransaction = _cache.getHighestTransaction(start, end);
    topVendor = _cache.getTopRecipient(start, end);
    avgDailySpending = _cache.getAvgDailySpending(start, end);
    mostSpentDay = _cache.getMostSpentDay(start, end);

    // Generate trend data
    _generateTrendData(start, end);
  }

  void _generateTrendData(DateTime? start, DateTime? end) {
    final effectiveStart = start ?? DateTime.now().subtract(const Duration(days: 30));
    final effectiveEnd = end ?? DateTime.now();

    // Get transactions in range
    final transactions = _cache.getTransactionsByDateRange(
      effectiveStart,
      effectiveEnd,
    );

    // Group by date and calculate daily net (income - expenses)
    Map<DateTime, double> dailyNet = {};

    for (var txn in transactions) {
      final date = DateTime(
        txn.timestamp.year,
        txn.timestamp.month,
        txn.timestamp.day,
      );

      if (!dailyNet.containsKey(date)) {
        dailyNet[date] = 0;
      }

      if (txn.isCredit) {
        dailyNet[date] = dailyNet[date]! + txn.amount;
      } else {
        dailyNet[date] = dailyNet[date]! - txn.amount;
      }
    }

    // Convert to list of points
    monthlyTrend = dailyNet.entries
        .map((e) => DailyTransactionPoint(date: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // If no data, create empty points for last 30 days
    if (monthlyTrend.isEmpty) {
      monthlyTrend = List.generate(
        30,
        (i) => DailyTransactionPoint(
          date: DateTime.now().subtract(Duration(days: 30 - i)),
          amount: 0,
        ),
      );
    }
  }

  Future<void> openDateRangePicker() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: selectedRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFFED1B2E),
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
        _calculateAnalytics();
      });
      _controller.forward(from: 0);
    }
  }

  Future<void> _refreshAnalytics() async {
    await _transactionService.getTransactions(forceRefresh: true);
    setState(() {
      _calculateAnalytics();
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void openTransactionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Analytics",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF212121)),
            onPressed: _refreshAnalytics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5F6),
              Colors.white,
            ],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFED1B2E)),
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: _refreshAnalytics,
                  color: const Color(0xFFED1B2E),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Date Range Selector
                      GestureDetector(
                        onTap: openDateRangePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 18),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFED1B2E).withOpacity(0.12),
                                const Color(0xFFED1B2E).withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFFED1B2E).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                size: 20,
                                color: Color(0xFFED1B2E),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                getRangeLabel(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFFED1B2E),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.expand_more,
                                size: 20,
                                color: Color(0xFFED1B2E),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Monthly Trend Chart
                      TrendChart(data: monthlyTrend),

                      const SizedBox(height: 20),

                      // Income vs Expense
                      IncomeExpenseRatio(
                        income: totalIncome,
                        expense: totalExpenses,
                      ),

                      const SizedBox(height: 25),

                      // Key Insights
                      const Text(
                        "Key Insights",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF212121)),
                      ),
                      const SizedBox(height: 12),

                      InsightCard(
                        title: "Highest Transaction",
                        value: "₦${highestTransaction.toStringAsFixed(0)}",
                        icon: Icons.trending_up,
                      ),

                      InsightCard(
                        title: "Top Recipient",
                        value: topVendor,
                        icon: Icons.people_outline_rounded,
                      ),

                      InsightCard(
                        title: "Avg Daily Spending",
                        value: "₦${avgDailySpending.toStringAsFixed(0)}",
                        icon: Icons.today,
                      ),

                      InsightCard(
                        title: "Most Spent Day",
                        value: mostSpentDay,
                        icon: Icons.calendar_month_rounded,
                      ),

                      const SizedBox(height: 20),

                      // View Transaction History Button
                      TextButton(
                        onPressed: openTransactionHistory,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFED1B2E),
                        ),
                        child: const Text(
                          "View Transaction History",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}