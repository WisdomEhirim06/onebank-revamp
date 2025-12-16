import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_input_field.dart';
import '../widgets/animated_progress_bar.dart';
import '../widgets/otp_input.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/pin_input.dart';
import '../widgets/resend_timer.dart';
import 'success_screen.dart';

class SignUpFlow extends StatefulWidget {
  const SignUpFlow({super.key});

  @override
  State<SignUpFlow> createState() => _SignUpFlowState();
}

class _SignUpFlowState extends State<SignUpFlow> with TickerProviderStateMixin {
  int step = 1;
  bool isLoading = false;

  // Form data
  String fullName = '';
  String email = '';
  String phone = '';
  String nin = '';
  String password = '';
  String confirmPassword = '';
  String otp = '';
  String pin = '';
  String confirmPin = '';

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
        if (fullName.trim().isEmpty) {
          _showError('Please enter your full name');
          return false;
        }
        if (email.trim().isEmpty || !email.contains('@')) {
          _showError('Please enter a valid email address');
          return false;
        }
        if (phone.trim().isEmpty) {
          _showError('Please enter your phone number');
          return false;
        }
        return true;

      case 2:
        if (nin.trim().isEmpty || nin.trim().length < 11) {
          _showError('Please enter a valid NIN (11 digits)');
          return false;
        }
        return true;

      case 3:
        if (otp.length != 6) {
          _showError('Please enter the complete 6-digit code');
          return false;
        }
        // In a real app, verify OTP with backend here
        _showSuccess("OTP verified successfully");
        return true;

      case 4:
        if (password.isEmpty || password.length < 8) {
          _showError('Password must be at least 8 characters');
          return false;
        }
        if (password != confirmPassword) {
          _showError('Passwords do not match');
          return false;
        }
        return true;

      case 5:
        if (pin.length != 4) {
          _showError('PIN must be 4 digits');
          return false;
        }
        if (pin != confirmPin) {
          _showError('PINs do not match');
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

  void nextStep()  {
    if (!validateStep()) return;

    if (step < 5) {
      setState(() => step++);
      _controller.reset();
      _controller.forward();
    } else {
      // Final step - create account
      _createAccount();
    }
  }

  Future<void> _createAccount() async {
    setState(() => isLoading = true);

    try {
      final error = await _authService.signUpUser(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        nin: nin.trim(),
        password: password.trim(),
        pin: pin,
      );

      setState(() => isLoading = false);

      if (error == null) {
        // Success
        _showSuccess('Account created successfully!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacement(
              context, createRoute(const SuccessScreen()));
        }
      } else {
        // Error
        _showError(error);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('An unexpected error occurred. Please try again.');
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
                  AnimatedProgressBar(progress: step / 5),
                  if (step > 1)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Color(0xFF1C1C1C)),
                            onPressed: isLoading ? null : prevStep,
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
                                'Create Account',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C1C1C)),
                              ),
                              const SizedBox(height: 40),
                              if (step == 1) ...[
                                AnimatedInputField(
                                  label: 'Full name',
                                  hint: 'Enter your full name',
                                  onChanged: (val) =>
                                      setState(() => fullName = val),
                                ),
                                const SizedBox(height: 20),
                                AnimatedInputField(
                                  label: 'Email',
                                  hint: 'Enter your email address',
                                  onChanged: (val) =>
                                      setState(() => email = val),
                                ),
                                const SizedBox(height: 20),
                                AnimatedInputField(
                                  label: 'Phone number',
                                  hint: 'Enter your phone number',
                                  onChanged: (val) =>
                                      setState(() => phone = val),
                                ),
                              ],
                              if (step == 2) ...[
                                const Text(
                                  'Verify Your Identity',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1C1C1C)),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Enter your NIN so we can securely verify your identity.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF757575),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                AnimatedInputField(
                                  label: 'NIN',
                                  hint:
                                      'Enter your National Identification Number',
                                  onChanged: (val) => setState(() => nin = val),
                                ),
                              ],
                              if (step == 3) ...[
                                const Text(
                                  'Verify Your Number',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C1C1C),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                OTPInput(
                                  onChanged: (value) =>
                                      setState(() => otp = value),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Enter the 6-digit code sent to your phone.',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF757575)),
                                ),
                                const SizedBox(height: 20),
                                const ResendTimer(),
                              ],
                              if (step == 4) ...[
                                const Text(
                                  'Secure Your Account',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1C1C1C)),
                                ),
                                const SizedBox(height: 20),
                                AnimatedInputField(
                                  label: 'Create password',
                                  hint: 'Enter password',
                                  isPassword: true,
                                  onChanged: (val) =>
                                      setState(() => password = val),
                                ),
                                const SizedBox(height: 25),
                                PasswordStrengthIndicator(password: password),
                                const SizedBox(height: 25),
                                AnimatedInputField(
                                  label: 'Confirm password',
                                  hint: 'Re-enter password',
                                  isPassword: true,
                                  onChanged: (val) =>
                                      setState(() => confirmPassword = val),
                                ),
                                const SizedBox(height: 30),
                              ],
                              if (step == 5) ...[
                                const Text(
                                  'Create Transaction PIN',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1C1C1C)),
                                ),
                                const SizedBox(height: 15),
                                PINInput(
                                  onChanged: (value) =>
                                      setState(() => pin = value),
                                ),
                                const SizedBox(height: 25),
                                const Text(
                                  'Re-enter your 4-digit PIN to confirm.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                PINInput(
                                  onChanged: (value) =>
                                      setState(() => confirmPin = value),
                                ),
                                const SizedBox(height: 25),
                              ],
                              const SizedBox(height: 40),
                              AnimatedButton(
                                text: step == 5 ? 'Create Account' : 'Continue',
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