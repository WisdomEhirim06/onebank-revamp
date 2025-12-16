import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/animated_button.dart';
import 'signin_flow_screen.dart';
import 'signup_flow_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFED1B2E), Color(0xFFB8132A), Color(0xFF8B0F1F)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                  top: 80,
                  right: -40,
                  child: _buildCircle(140, Colors.white.withOpacity(0.1))),
              Positioned(
                  bottom: 150,
                  left: -60,
                  child: _buildCircle(180, Colors.white.withOpacity(0.08))),
              Positioned(
                  top: 300,
                  left: 30,
                  child: _buildCircle(60, Colors.white.withOpacity(0.12))),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.account_balance,
                            size: 50, color: Color(0xFFED1B2E)),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Welcome to',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sterling OneBank',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Banking made simple, secure, and smart.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const Spacer(),
                      AnimatedButton(
                        text: 'Sign In',
                        isPrimary: true,
                        onPressed: () {
                          Navigator.push(
                              context, createRoute(const SignInFlow()));
                        },
                      ),
                      const SizedBox(height: 16),
                      AnimatedButton(
                        text: 'Create Account',
                        isPrimary: false,
                        onPressed: () {
                          Navigator.push(
                              context, createRoute(const SignUpFlow()));
                        },
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}