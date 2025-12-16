import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> allTransactions = [];
  List<TransactionModel> filteredTransactions = [];
  DateTimeRange? selectedRange;
  late AnimationController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _loadTransactions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);

    final transactions = await _transactionService.getTransactions();

    setState(() {
      allTransactions = transactions;
      filteredTransactions = List.from(transactions);
      isLoading = false;
    });

    _controller.forward();
  }

  Future<void> _refreshTransactions() async {
    final transactions = await _transactionService.getTransactions(
      forceRefresh: true,
    );

    setState(() {
      allTransactions = transactions;
      if (selectedRange == null) {
        filteredTransactions = List.from(transactions);
      } else {
        _filterByDateRange(selectedRange!);
      }
    });

    _controller.forward(from: 0);
  }

  Future<void> pickDateRange() async {
    DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
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

    if (range == null) return;

    setState(() {
      selectedRange = range;
      _filterByDateRange(range);
    });

    _controller.forward(from: 0);
  }

  void _filterByDateRange(DateTimeRange range) {
    filteredTransactions = allTransactions.where((txn) {
      return txn.timestamp.isAfter(range.start) &&
          txn.timestamp
              .isBefore(range.end.add(const Duration(days: 1)));
    }).toList();
  }

  void clearFilter() {
    setState(() {
      selectedRange = null;
      filteredTransactions = List.from(allTransactions);
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(filteredTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (selectedRange != null)
            IconButton(
              onPressed: clearFilter,
              icon: const Icon(Icons.clear),
              tooltip: "Clear filter",
            ),
          IconButton(
            onPressed: pickDateRange,
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: "Filter by date",
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFED1B2E)),
              ),
            )
          : filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        selectedRange != null
                            ? "No transactions in this date range."
                            : "No transactions yet.",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                      if (selectedRange != null) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: clearFilter,
                          child: const Text('View All Transactions'),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshTransactions,
                  color: const Color(0xFFED1B2E),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: _buildAnimatedGroups(grouped),
                  ),
                ),
    );
  }

  List<Widget> _buildAnimatedGroups(
      Map<String, List<TransactionModel>> grouped) {
    List<Widget> widgets = [];
    int globalIndex = 0;

    for (var entry in grouped.entries) {
      // Date header
      final headerAnimation = CurvedAnimation(
        parent: _controller,
        curve: Interval(
          globalIndex * 0.08,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      );

      widgets.add(
        FadeTransition(
          opacity: headerAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(headerAnimation),
            child: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),
          ),
        ),
      );

      widgets.add(const SizedBox(height: 10));
      globalIndex++;

      // Transaction tiles
      for (var t in entry.value) {
        final tileAnimation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            globalIndex * 0.08,
            1.0,
            curve: Curves.easeOutCubic,
          ),
        );

        widgets.add(
          FadeTransition(
            opacity: tileAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(tileAnimation),
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
            ),
          ),
        );
        globalIndex++;
      }

      widgets.add(const SizedBox(height: 24));
    }

    return widgets;
  }

  Map<String, List<TransactionModel>> _groupByDate(
      List<TransactionModel> txns) {
    Map<String, List<TransactionModel>> grouped = {};

    for (var t in txns) {
      String key =
          "${t.timestamp.day} ${_month(t.timestamp.month)} ${t.timestamp.year}";
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
    }
    return grouped;
  }

  String _month(int m) {
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
    return months[m - 1];
  }
}