import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'user_session.dart';
import 'transaction_service.dart';
import 'notification_service.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TransactionService _transactionService = TransactionService();

  /// SIGN UP
  Future<String?> signUpUser({
    required String fullName,
    required String email,
    required String phone,
    required String nin,
    required String password,
    required String pin,
  }) async {
    try {
      // Create Firebase Auth account
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Build user model
      final user = UserModel(
        uid: cred.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        nin: nin,
        pin: pin,
        createdAt: DateTime.now().toIso8601String(),
        balance: 2000000.0
      );

      // Save to Firestore
      await _db.collection("users").doc(user.uid).set(user.toMap());

      // Then Create account with balance of 2,000,000
      final accountError = await _transactionService.createAccount(
        userId: user.uid,
        initialBalance: 2000000.0,
      );

      if (accountError != null) {
        // account creation failed, but user is created
        print('Warning: Account creation failed - $accountError');
      }
      // Store in memory session immediately
      UserSession().setUser(user);
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// SIGN IN
  Future<String?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred =  await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Fetch firestore data
      DocumentSnapshot snapshot = await _db.collection("users").doc(cred.user!.uid).get();

      if (!snapshot.exists) {
        return 'User data not found. Please check if you have an account';
      }

      final userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);

      UserSession().setUser(userModel);
      try {
        await NotificationService().initialize();
        print('✅ Notifications initialized after sign-in');
      } catch (e) {
        print('Notfication init failed: $e');
      }
      

      // preload account transactions
      await _transactionService.getAccount(forceRefresh: true);
      await _transactionService.getTransactions(forceRefresh: true);
      
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // GET CURRENT USER FROM SESSION
  UserModel? getCurrentUserData() {
    return UserSession().currentUser;
  }
  /// GET CURRENT AUTH USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// GET USER EMAIL
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  /// REFRESH USER DATA FROM FIRESTORE
  Future<String?> refreshUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in';

      DocumentSnapshot snapshot = await _db.collection("users").doc(user.uid).get();
      
      if (!snapshot.exists) {
        return 'User data not found';
      }

      final userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      UserSession().setUser(userModel);
      
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();

    await NotificationService().clearToken();

    UserSession().clear(); // Clear session data
    _transactionService.clearCache(); // Clear transaction cache
  }
}
