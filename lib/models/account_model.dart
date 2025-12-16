class AccountModel {
  final String userId;
  final double balance;
  final String accountNumber;
  final DateTime lastUpdated;

  AccountModel({
    required this.userId,
    required this.balance,
    required this.accountNumber,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balance': balance,
      'accountNumber': accountNumber,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      userId: map['userId'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      accountNumber: map['accountNumber'] ?? '',
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  AccountModel copyWith({
    String? userId,
    double? balance,
    String? accountNumber,
    DateTime? lastUpdated,
  }) {
    return AccountModel(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      accountNumber: accountNumber ?? this.accountNumber,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}