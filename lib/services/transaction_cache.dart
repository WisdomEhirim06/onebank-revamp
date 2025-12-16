import '../models/transaction_model.dart';
import '../models/account_model.dart';

class TransactionCache {
  static final TransactionCache _instance = TransactionCache._internal();
  factory TransactionCache() => _instance;
  TransactionCache._internal();

  List<TransactionModel> _transactions = [];
  AccountModel? _account;
  DateTime? _lastFetch;

  // Cache expiry duration (5 minutes)
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Getters
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  AccountModel? get account => _account;
  bool get isCacheValid {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < _cacheExpiry;
  }

  // Set transactions
  void setTransactions(List<TransactionModel> transactions) {
    _transactions = transactions;
    _lastFetch = DateTime.now();
  }

  // Add single transaction (for new transfers)
  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction); // Add to beginning (most recent)
    _lastFetch = DateTime.now();
  }

  // Set account
  void setAccount(AccountModel account) {
    _account = account;
  }

  // Update balance
  void updateBalance(double newBalance) {
    if (_account != null) {
      _account = _account!.copyWith(
        balance: newBalance,
        lastUpdated: DateTime.now(),
      );
    }
  }

  // Get transactions by date range
  List<TransactionModel> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _transactions.where((txn) {
      return txn.timestamp.isAfter(start) && 
             txn.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get credit transactions (income)
  List<TransactionModel> getCreditTransactions() {
    return _transactions.where((txn) => txn.isCredit).toList();
  }

  // Get debit transactions (expenses)
  List<TransactionModel> getDebitTransactions() {
    return _transactions.where((txn) => !txn.isCredit).toList();
  }

  // Calculate total income
  double getTotalIncome([DateTime? start, DateTime? end]) {
    var txns = _transactions.where((txn) => txn.isCredit);
    
    if (start != null && end != null) {
      txns = txns.where((txn) => 
        txn.timestamp.isAfter(start) && 
        txn.timestamp.isBefore(end.add(const Duration(days: 1)))
      );
    }
    
    return txns.fold(0.0, (sum, txn) => sum + txn.amount);
  }

  // Calculate total expenses
  double getTotalExpenses([DateTime? start, DateTime? end]) {
    var txns = _transactions.where((txn) => !txn.isCredit);
    
    if (start != null && end != null) {
      txns = txns.where((txn) => 
        txn.timestamp.isAfter(start) && 
        txn.timestamp.isBefore(end.add(const Duration(days: 1)))
      );
    }
    
    return txns.fold(0.0, (sum, txn) => sum + txn.amount);
  }

  // Get highest transaction
  double getHighestTransaction([DateTime? start, DateTime? end]) {
    var txns = _transactions;
    
    if (start != null && end != null) {
      txns = _transactions.where((txn) => 
        txn.timestamp.isAfter(start) && 
        txn.timestamp.isBefore(end.add(const Duration(days: 1)))
      ).toList();
    }
    
    if (txns.isEmpty) return 0.0;
    
    return txns.map((t) => t.amount).reduce((a, b) => a > b ? a : b);
  }

  // Get top recipient
  String getTopRecipient([DateTime? start, DateTime? end]) {
    var txns = _transactions.where((txn) => !txn.isCredit);
    
    if (start != null && end != null) {
      txns = txns.where((txn) => 
        txn.timestamp.isAfter(start) && 
        txn.timestamp.isBefore(end.add(const Duration(days: 1)))
      );
    }
    
    if (txns.isEmpty) return '—';
    
    // Count occurrences
    Map<String, int> recipientCount = {};
    for (var txn in txns) {
      recipientCount[txn.recipientName] = 
        (recipientCount[txn.recipientName] ?? 0) + 1;
    }
    
    // Find most frequent
    var sorted = recipientCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }

  // Get average daily spending
  double getAvgDailySpending([DateTime? start, DateTime? end]) {
    var effectiveStart = start ?? DateTime.now().subtract(const Duration(days: 30));
    var effectiveEnd = end ?? DateTime.now();
    
    final days = effectiveEnd.difference(effectiveStart).inDays + 1;
    final totalExpenses = getTotalExpenses(effectiveStart, effectiveEnd);
    
    return days > 0 ? totalExpenses / days : 0.0;
  }

  // Get most spent day of week
  String getMostSpentDay([DateTime? start, DateTime? end]) {
    var txns = _transactions.where((txn) => !txn.isCredit);
    
    if (start != null && end != null) {
      txns = txns.where((txn) => 
        txn.timestamp.isAfter(start) && 
        txn.timestamp.isBefore(end.add(const Duration(days: 1)))
      );
    }
    
    if (txns.isEmpty) return '—';
    
    // Group by day of week and sum amounts
    Map<int, double> dayTotals = {};
    for (var txn in txns) {
      final day = txn.timestamp.weekday;
      dayTotals[day] = (dayTotals[day] ?? 0) + txn.amount;
    }
    
    if (dayTotals.isEmpty) return '—';
    
    // Find day with highest total
    var sorted = dayTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[sorted.first.key - 1];
  }

  // Clear cache
  void clear() {
    _transactions = [];
    _account = null;
    _lastFetch = null;
  }

  // Force refresh flag
  void invalidateCache() {
    _lastFetch = null;
  }
}