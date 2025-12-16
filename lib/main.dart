import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  await NotificationService().initialize();

  runApp(const SterlingOneBankApp());
}

class SterlingOneBankApp extends StatelessWidget {
  const SterlingOneBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sterling OneBank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFED1B2E),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'System',
      ),
      home: const WelcomeScreen(),
    );
  }
}

Route createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}