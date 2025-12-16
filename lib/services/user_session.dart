import '../models/user_model.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  UserModel? currentUser;

  void setUser(UserModel user) {
    currentUser = user;
  }

  void clear() {
    currentUser = null;
  }
}