import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_input_field.dart';
import '../widgets/animated_progress_bar.dart';
import '../widgets/otp_input.dart';
import '../widgets/resend_timer.dart';
import 'dashboard_screen.dart';

class SignInFlow extends StatefulWidget {
  const SignInFlow({super.key});

  @override
  State<SignInFlow> createState() => _SignInFlowState();
}

class _SignInFlowState extends State<SignInFlow> with TickerProviderStateMixin {
  int step = 1;
  bool isLoading = false;

  // Form data
  String emailOrPhone = '';
  String password = '';
  String otp = '';

  final AuthService _authService = AuthService();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
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

  bool validateStep() {
    switch (step) {
      case 1:
        if (emailOrPhone.trim().isEmpty) {
          _showError('Please enter your email or phone number');
          return false;
        }
        return true;

      case 2:
        if (password.isEmpty) {
          _showError('Please enter your password');
          return false;
        }
        return true;

      case 3:
        if (otp.length != 6) {
          _showError('Please enter the complete 6-digit code');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void nextStep() {
    if (!validateStep()) return;

    if (step == 1) {
      // Move to password step
      setState(() => step++);
      _controller.reset();
      _controller.forward();
    } else if (step == 2) {
      // Attempt sign in
      _signInUser();
    } else if (step == 3) {
      // Verify OTP and complete sign in
      _verifyOTPAndSignIn();
    }
  }

  Future<void> _signInUser() async {
    setState(() => isLoading = true);

    try {
      final error = await _authService.signInUser(
        email: emailOrPhone.trim(),
        password: password.trim(),
      );

      setState(() => isLoading = false);

      if (error == null) {
        // Sign in successful, move to OTP verification
        _showSuccess('Credentials verified! Please enter OTP.');
        setState(() => step++);
        _controller.reset();
        _controller.forward();
      } else {
        // Show error
        _showError(error);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> _verifyOTPAndSignIn() async {
    setState(() => isLoading = true);

    // Simulate OTP verification (in production, verify with backend)
    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);

    // OTP verified, navigate to dashboard
    _showSuccess('Sign in successful!');
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        createRoute(const DashboardScreen()),
      );
    }
  }

  void prevStep() {
    if (step > 1) {
      setState(() => step--);
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF5F6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  AnimatedProgressBar(progress: step / 3),
                  if (step > 1)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Color(0xFF1C1C1C)),
                            onPressed: isLoading ? () {} : prevStep,
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              const Text(
                                'Sign In',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C1C1C)),
                              ),
                              const SizedBox(height: 40),
                              if (step == 1) ...[
                                AnimatedInputField(
                                  label: 'Phone number or email',
                                  hint: 'Enter your phone or email',
                                  onChanged: (val) =>
                                      setState(() => emailOrPhone = val),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Enter the phone number or email linked to your Sterling OneBank profile.',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF757575)),
                                ),
                              ],
                              if (step == 2) ...[
                                AnimatedInputField(
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  isPassword: true,
                                  onChanged: (val) =>
                                      setState(() => password = val),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Make sure this is your correct OneBank login password.',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF757575)),
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    // Implement forgot password flow
                                    _showError(
                                        'Forgot password feature coming soon!');
                                  },
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFED1B2E),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                              if (step == 3) ...[
                                const Text(
                                  'Enter Verification Code',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1C1C1C)),
                                ),
                                const SizedBox(height: 20),
                                OTPInput(
                                  onChanged: (value) =>
                                      setState(() => otp = value),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'A verification code has been sent to your registered number.',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF757575)),
                                ),
                                const SizedBox(height: 20),
                                const ResendTimer(),
                              ],
                              const SizedBox(height: 40),
                              AnimatedButton(
                                text:
                                    step == 3 ? 'Verify & Sign In' : 'Continue',
                                isPrimary: true,
                                onPressed: isLoading ? () {} : nextStep,
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFFF4757)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}