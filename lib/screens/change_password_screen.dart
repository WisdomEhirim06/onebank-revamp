import 'package:flutter/material.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_input_field.dart';
import '../widgets/animated_progress_bar.dart';
import '../widgets/otp_input.dart';
import '../widgets/password_strength_indicator.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with TickerProviderStateMixin {
  
  int step = 1;
  bool isSaved = false;
  String newPassword = "";

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 380), vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.25, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextStep() {
    if (step < 3) {
      // Normal transitions
      setState(() => step++);
      _controller.reset();
      _controller.forward();
    } else {
      // FINAL STEP — SAVE
      setState(() => isSaved = true);

      // After 1.2 seconds return to Profile
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context);
      });
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
          child: Column(
            children: [
              AnimatedProgressBar(progress: step / 3),

              // Back button
              if (step > 1)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1C)),
                      onPressed: prevStep,
                    ),
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

                          const SizedBox(height: 20),
                          const Text(
                            "Change Password",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1C),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // --- STEP 1: CURRENT PASSWORD ---
                          if (step == 1) ...[
                            AnimatedInputField(
                              label: "Current Password",
                              hint: "Enter your current password",
                              isPassword: true,
                              onChanged: (_) {},
                            ),
                          ],

                          // --- STEP 2: OTP ---
                          if (step == 2) ...[
                            const Text(
                              "Enter OTP",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            OTPInput(onChanged: (_) {}),
                            const SizedBox(height: 12),
                            const Text(
                              "Enter the 6-digit code sent to your phone.",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],

                          // --- STEP 3: NEW PASSWORD ---
                          if (step == 3) ...[
                            const Text(
                              "New Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),

                            AnimatedInputField(
                              label: "New Password",
                              hint: "Enter new password",
                              isPassword: true,
                              onChanged: (val) =>
                                  setState(() => newPassword = val),
                            ),

                            const SizedBox(height: 20),
                            PasswordStrengthIndicator(password: newPassword),

                            const SizedBox(height: 25),
                            AnimatedInputField(
                              label: "Confirm Password",
                              hint: "Re-enter password",
                              isPassword: true,
                              onChanged: (_) {},
                            ),
                          ],

                          if (isSaved) ...[
                            const SizedBox(height: 40),
                            Center(
                              child: Column(
                                children: const [
                                  Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF4BB543), size: 58),
                                  SizedBox(height: 14),
                                  Text(
                                    "Password Changed Successfully",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1C1C1C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                          ],

                          const SizedBox(height: 40),

                          AnimatedButton(
                            text: step == 3 ? "Save Password" : "Continue",
                            isPrimary: true,
                            onPressed: isSaved ? () {} : nextStep,
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
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
