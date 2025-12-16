import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import 'transaction_cache.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TransactionCache _cache = TransactionCache();

  // Generate a unique transaction reference
  String _generateTxnRef() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'TXN${timestamp}${random.toString().padLeft(4, '0')}';
  }

  /// GENERATE ACCOUNT NUMBER
  String generateAccountNumber() {
    final int offset = 1000000000; // ensures 10 digits
    final int maxExtra = 900000000; // safe bound for nextInt
    final int extra = Random().nextInt(maxExtra); // 0 .. maxExtra-1
    return (offset + extra).toString();
  }

  /// CREATE INITIAL ACCOUNT (Called during signup)
  Future<String?> createAccount({
    required String userId,
    double initialBalance = 2000000.0,
  }) async {
    try {
      final accountNumber = generateAccountNumber();
      
      final account = AccountModel(
        userId: userId,
        balance: initialBalance,
        accountNumber: accountNumber,
        lastUpdated: DateTime.now(),
      );

      await _db.collection('accounts').doc(userId).set(account.toMap());
      
      // Cache the account
      _cache.setAccount(account);

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  /// GET ACCOUNT BALANCE
  Future<AccountModel?> getAccount({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Return cached account if valid
    if (!forceRefresh && _cache.account != null) {
      return _cache.account;
    }

    try {
      final doc = await _db.collection('accounts').doc(user.uid).get();
      
      if (!doc.exists) {
        print('Account not found, creating a new one');
        final error = await createAccount(
          userId: user.uid,
          initialBalance: 2000000.0,
        );

        if (error != null) {
          print('Failed to create account: $error');
          return null;
        }

        final newDoc = await _db.collection('accounts').doc(user.uid).get();
        if (newDoc.exists) {
          final account = AccountModel.fromMap(newDoc.data()!);
          _cache.setAccount(account);
          return account;
        }
        return null;
      }

      final account = AccountModel.fromMap(doc.data()!);
      _cache.setAccount(account);
      
      return account;
    } catch (e) {
      print('Error fetching account: $e');
      return null;
    }
  }

  /// GET TRANSACTIONS
  Future<List<TransactionModel>> getTransactions({
    bool forceRefresh = false,
    int limit = 100,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    // Return cached transactions if valid
    if (!forceRefresh && _cache.isCacheValid) {
      return _cache.transactions;
    }

    try {
      final snapshot = await _db
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();

      _cache.setTransactions(transactions);

      return transactions;
    } catch (e) {
      print('Error fetching transactions: $e');
      return _cache.transactions; // Return cached on error
    }
  }

  /// LOOKUP ACCOUNT BY ACCOUNT NUMBER
  Future<Map<String, dynamic>> lookupAccount(String accountNumber) async {
    try {
      final snapshot = await _db
          .collection('accounts')
          .where('accountNumber', isEqualTo: accountNumber.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'found': false,
          'message': 'Account not found',
        };
      }

      final accountData = snapshot.docs.first.data();
      final userId = accountData['userId'];

      // Get user details
      final userDoc = await _db.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {
          'found': false,
          'message': 'User not found for this account',
        };
      }

      final userData = userDoc.data()!;

      return {
        'found': true,
        'recipientName': userData['fullName'],
        'accountNumber': accountData['accountNumber'],
        'recipientUserId': userId,
        'bank': 'Sterling OneBank',
      };
    } catch (e) {
      print('Account lookup error: $e');
      return {
        'found': false,
        'message': 'Error looking up account',
      };
    }
  }

  /// CREATE TRANSFER - ACID COMPLIANT
  Future<Map<String, dynamic>> createTransfer({
    required String senderName,
    required String recipientName,
    required String accountNumber,
    required String bank,
    required double amount,
    required String description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return {
        'success': false,
        'error': 'User not authenticated',
      };
    }

    try {
      // Lookup recipient first (outside transaction for performance)
      final lookup = await lookupAccount(accountNumber);
      if (!lookup['found']) {
        return {'success': false, 'error': 'Recipient account not found'};
      }

      final recipientUserId = lookup['recipientUserId'] as String;
      final txnRef = _generateTxnRef();
      final timestamp = DateTime.now();

      // Use Firestore TRANSACTION for ACID compliance
      final result = await _db.runTransaction<Map<String, dynamic>>(
        (transaction) async {
          // 1. READ: Get sender account with lock
          final senderRef = _db.collection('accounts').doc(user.uid);
          final senderSnapshot = await transaction.get(senderRef);

          if (!senderSnapshot.exists) {
            throw Exception('Sender account not found');
          }

          final senderAccount = AccountModel.fromMap(senderSnapshot.data()!);

          // 2. VALIDATE: Check sufficient balance (inside transaction)
          if (senderAccount.balance < amount) {
            throw Exception(
              'Insufficient balance. You have ₦${senderAccount.balance.toStringAsFixed(2)}',
            );
          }

          // 3. READ: Get recipient account with lock
          final recipientRef = _db.collection('accounts').doc(recipientUserId);
          final recipientSnapshot = await transaction.get(recipientRef);

          if (!recipientSnapshot.exists) {
            throw Exception('Recipient account not found');
          }

          final recipientAccount = AccountModel.fromMap(recipientSnapshot.data()!);

          // 4. CREATE: Transaction records
          final senderTxnId = _db.collection('transactions').doc().id;
          final recipientTxnId = _db.collection('transactions').doc().id;

          final senderTxn = TransactionModel(
            id: senderTxnId,
            userId: user.uid,
            senderName: senderName,
            recipientName: recipientName,
            accountNumber: accountNumber,
            bank: bank,
            amount: amount,
            isCredit: false,
            timestamp: timestamp,
            description: description,
            txnRef: txnRef,
            type: 'transfer',
            status: 'completed',
          );

          final recipientTxn = TransactionModel(
            id: recipientTxnId,
            userId: recipientUserId,
            senderName: senderName,
            recipientName: recipientName,
            accountNumber: senderAccount.accountNumber,
            bank: 'Sterling OneBank',
            amount: amount,
            isCredit: true,
            timestamp: timestamp,
            description: description,
            txnRef: txnRef,
            type: 'transfer',
            status: 'completed',
          );

          // 5. WRITE: All operations atomically
          // Save sender transaction
          transaction.set(
            _db.collection('transactions').doc(senderTxnId),
            senderTxn.toMap(),
          );

          // Save recipient transaction
          transaction.set(
            _db.collection('transactions').doc(recipientTxnId),
            recipientTxn.toMap(),
          );

          // Update sender balance (debit)
          final newSenderBalance = senderAccount.balance - amount;
          transaction.update(senderRef, {
            'balance': newSenderBalance,
            'lastUpdated': timestamp.toIso8601String(),
          });

          // Update recipient balance (credit)
          final newRecipientBalance = recipientAccount.balance + amount;
          transaction.update(recipientRef, {
            'balance': newRecipientBalance,
            'lastUpdated': timestamp.toIso8601String(),
          });

          print('✅ ACID transfer: ₦$amount from ${user.uid} to $recipientUserId');

          // Return result data
          return {
            'success': true,
            'transaction': senderTxn,
            'newBalance': newSenderBalance,
            'isInterAccount': true,
          };
        },
        timeout: const Duration(seconds: 30),
      );

      // 6. UPDATE CACHE (after successful commit)
      final txn = result['transaction'] as TransactionModel;
      final newBalance = result['newBalance'] as double;

      _cache.addTransaction(txn);
      _cache.updateBalance(newBalance);

      // Invalidate recipient cache (if they're logged in elsewhere)
      if (recipientUserId != user.uid) {
        TransactionCache().invalidateCache();
      }

      // 7. SEND CREDIT ALERT TO RECIPIENT
      await _sendCreditAlert(
        recipientUserId: recipientUserId,
        senderName: senderName,
        amount: amount,
        txnRef: txnRef,
      );

      return result;

    } on FirebaseException catch (e) {
      print('❌ Firestore error: ${e.message}');
      if (e.code == 'aborted') {
        return {
          'success': false,
          'error': 'Transaction failed due to concurrent update. Please try again.',
        };
      }
      return {
        'success': false,
        'error': e.message ?? 'Transaction failed',
      };
    } catch (e) {
      print('❌ Transfer error: $e');
      return {
        'success': false,
        'error': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// ADD INCOME/CREDIT TRANSACTION (for testing/demo)
  Future<String?> addIncomeTransaction({
    required String senderName,
    required double amount,
    required String description,
    String type = 'deposit',
  }) async {
    final user = _auth.currentUser;
    if (user == null) return 'User not authenticated';

    try {
      final account = await getAccount();
      if (account == null) return 'Account not found';

      final txnRef = _generateTxnRef();
      final timestamp = DateTime.now();

      final transaction = TransactionModel(
        id: _db.collection('transactions').doc().id,
        userId: user.uid,
        senderName: senderName,
        recipientName: user.displayName ?? 'You',
        accountNumber: account.accountNumber,
        bank: 'Sterling Bank',
        amount: amount,
        isCredit: true,
        timestamp: timestamp,
        description: description,
        txnRef: txnRef,
        type: type,
        status: 'completed',
      );

      final batch = _db.batch();

      batch.set(
        _db.collection('transactions').doc(transaction.id),
        transaction.toMap(),
      );

      final newBalance = account.balance + amount;
      batch.update(
        _db.collection('accounts').doc(user.uid),
        {
          'balance': newBalance,
          'lastUpdated': timestamp.toIso8601String(),
        },
      );

      await batch.commit();

      _cache.addTransaction(transaction);
      _cache.updateBalance(newBalance);

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  /// GET TRANSACTIONS BY DATE RANGE
  Future<List<TransactionModel>> getTransactionsByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _db
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: end.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching transactions by date: $e');
      // Fallback to cached data filtered by date
      return _cache.getTransactionsByDateRange(start, end);
    }
  }

  /// REFRESH ALL DATA
  Future<void> refreshAllData() async {
    await getAccount(forceRefresh: true);
    await getTransactions(forceRefresh: true);
  }

  /// CLEAR CACHE
  void clearCache() {
    _cache.clear();
  }

  /// SEND CREDIT ALERT TO RECIPIENT
  Future<void> _sendCreditAlert({
    required String recipientUserId,
    required String senderName,
    required double amount,
    required String txnRef,
  }) async {
    try {
      // Get recipient's FCM token
      final tokenDoc = await _db.collection('fcm_tokens').doc(recipientUserId).get();
      
      if (!tokenDoc.exists) {
        print('⚠️ No FCM token for recipient');
        return;
      }

      final recipientToken = tokenDoc.data()?['token'];
      if (recipientToken == null) return;

      // Store notification request in Firestore
      // Cloud Function will pick this up and send the actual notification
      await _db.collection('notification_queue').add({
        'recipientUserId': recipientUserId,
        'recipientToken': recipientToken,
        'type': 'credit_alert',
        'title': 'Credit Alert! 💰',
        'body': 'You received ₦${amount.toStringAsFixed(2)} from $senderName',
        'data': {
          'type': 'credit_alert',
          'amount': amount.toString(),
          'senderName': senderName,
          'txnRef': txnRef,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

      print('✅ Credit alert queued for $recipientUserId');
    } catch (e) {
      print('❌ Error sending credit alert: $e');
    }
  }
}