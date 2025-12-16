class TransactionModel {
  final String id; // Unique transaction ID
  final String userId; // Owner of the transaction
  final String senderName;
  final String recipientName;
  final String accountNumber;
  final String bank;
  final double amount;
  final bool isCredit; // true = money in, false = money out
  final DateTime timestamp;
  final String description;
  final String txnRef; // Transaction reference
  final String type; // 'transfer', 'deposit', 'withdrawal', 'salary', etc.
  final String status; // 'completed', 'pending', 'failed'

  TransactionModel({
    required this.id,
    required this.userId,
    required this.senderName,
    required this.recipientName,
    required this.accountNumber,
    required this.bank,
    required this.amount,
    required this.isCredit,
    required this.timestamp,
    required this.description,
    required this.txnRef,
    this.type = 'transfer',
    this.status = 'completed',
  });

  // For display purposes
  String get title {
    if (isCredit) {
      return 'From $senderName';
    } else {
      return 'To $recipientName';
    }
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'senderName': senderName,
      'recipientName': recipientName,
      'accountNumber': accountNumber,
      'bank': bank,
      'amount': amount,
      'isCredit': isCredit,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'txnRef': txnRef,
      'type': type,
      'status': status,
    };
  }

  // Create from Firestore map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      senderName: map['senderName'] ?? '',
      recipientName: map['recipientName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      bank: map['bank'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      isCredit: map['isCredit'] ?? false,
      timestamp: DateTime.parse(map['timestamp']),
      description: map['description'] ?? '',
      txnRef: map['txnRef'] ?? '',
      type: map['type'] ?? 'transfer',
      status: map['status'] ?? 'completed',
    );
  }

  // Copy with method for updates
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? senderName,
    String? recipientName,
    String? accountNumber,
    String? bank,
    double? amount,
    bool? isCredit,
    DateTime? timestamp,
    String? description,
    String? txnRef,
    String? type,
    String? status,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      senderName: senderName ?? this.senderName,
      recipientName: recipientName ?? this.recipientName,
      accountNumber: accountNumber ?? this.accountNumber,
      bank: bank ?? this.bank,
      amount: amount ?? this.amount,
      isCredit: isCredit ?? this.isCredit,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      txnRef: txnRef ?? this.txnRef,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}