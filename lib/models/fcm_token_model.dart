class FCMTokenModel {
  final String userId;
  final String token;
  final DateTime lastUpdated;
  final String platform; // 'android' or 'ios'

  FCMTokenModel({
    required this.userId,
    required this.token,
    required this.lastUpdated,
    required this.platform,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'token': token,
      'lastUpdated': lastUpdated.toIso8601String(),
      'platform': platform,
    };
  }

  factory FCMTokenModel.fromMap(Map<String, dynamic> map) {
    return FCMTokenModel(
      userId: map['userId'] ?? '',
      token: map['token'] ?? '',
      lastUpdated: DateTime.parse(map['lastUpdated']),
      platform: map['platform'] ?? 'android',
    );
  }
}