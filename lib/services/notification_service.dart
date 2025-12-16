import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// INITIALIZE NOTIFICATIONS
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Get FCM token
        final token = await _fcm.getToken();
        if (token != null) {
          await _saveFCMToken(token);
        }

        // Listen for token refresh
        _fcm.onTokenRefresh.listen(_saveFCMToken);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        _initialized = true;
      } else {
        print('⚠️ Notification permission denied');
      }
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  /// INITIALIZE LOCAL NOTIFICATIONS
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        _handleLocalNotificationTap(details);
      },
    );
  }

  /// SAVE FCM TOKEN TO FIRESTORE
  Future<void> _saveFCMToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('fcm_tokens').doc(user.uid).set({
        'userId': user.uid,
        'token': token,
        'lastUpdated': FieldValue.serverTimestamp(),
        'platform': Platform.isAndroid ? 'android' : 'ios',
      });
      print('✅ FCM token saved: ${token.substring(0, 20)}...');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// HANDLE FOREGROUND MESSAGE
  void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'OneBank',
        body: message.notification!.body ?? '',
        payload: message.data['type'] ?? '',
      );
    }
  }

  /// SHOW LOCAL NOTIFICATION
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'onebank_channel',
      'OneBank Notifications',
      channelDescription: 'Receive alerts for transactions and insights',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFED1B2E),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// HANDLE NOTIFICATION TAP (from background)
  void _handleNotificationTap(RemoteMessage message) {
    print('📱 Notification tapped: ${message.data}');
    final type = message.data['type'];

    // Navigate based on notification type
    if (type == 'credit_alert') {
      // Navigate to transaction history
      // navigationService.navigateTo('/transactions');
    } else if (type == 'weekly_insights') {
      // Navigate to analytics
      // navigationService.navigateTo('/analytics');
    }
  }

  /// HANDLE LOCAL NOTIFICATION TAP
  void _handleLocalNotificationTap(NotificationResponse details) {
    print('📱 Local notification tapped: ${details.payload}');
    // Handle navigation based on payload
  }

  /// CLEAR TOKEN ON LOGOUT
  Future<void> clearToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('fcm_tokens').doc(user.uid).delete();
      print('✅ FCM token cleared');
    } catch (e) {
      print('❌ Error clearing FCM token: $e');
    }
  }
}