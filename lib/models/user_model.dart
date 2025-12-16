class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String nin;
  final String pin;
  final String createdAt;
  final double balance;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.nin,
    required this.pin,
    required this.createdAt,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'nin': nin,
      'pin': pin,
      'createdAt': createdAt,
      'balance': balance,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      nin: map['nin'] ?? '',
      pin: map['pin'] ?? '',
      createdAt: map['createdAt'] ?? '',
      balance: (map['balance'] is num) ? (map['balance'] as num).toDouble() : 0.0,
    );
  }

}