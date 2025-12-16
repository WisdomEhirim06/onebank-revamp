import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../services/auth_service.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_option_tile.dart';
import '../widgets/section_divider.dart';
import 'change_password_screen.dart';
import 'change_pin_screen.dart';
import 'signin_flow_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  void _changePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  void _changePin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePinScreen()),
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Perform logout
    setState(() => _isLoggingOut = true);

    try {
      await _authService.signOut();

      if (mounted) {
        // Navigate to sign-in screen and clear navigation stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInFlow()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoggingOut = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession().currentUser;

    // Handle case where user data is not available
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            "Profile",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No user data available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4757),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: const Text(
              "Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile header with real user data
              ProfileHeader(
                name: user.fullName,
                email: user.email,
                phone: user.phone,
              ),

              const SizedBox(height: 30),

              const SectionDivider(title: "Account Settings"),
              const SizedBox(height: 10),

              ProfileOptionTile(
                icon: Icons.security_outlined,
                title: "Change Password",
                onTap: () => _changePassword(context),
              ),

              const SizedBox(height: 25),

              ProfileOptionTile(
                icon: Icons.pin_rounded,
                title: "Change Pin",
                onTap: () => _changePin(context),
              ),

              const SizedBox(height: 25),

              const SectionDivider(title: "General"),
              const SizedBox(height: 10),

              ProfileOptionTile(
                icon: Icons.logout_rounded,
                title: "Logout",
                isDestructive: true,
                onTap: () => _logout(context),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
        
        // Loading overlay during logout
        if (_isLoggingOut)
          Container(
            color: Colors.black26,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF4757),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Logging out...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}