import 'package:flutter/material.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_input_field.dart';
import '../widgets/animated_progress_bar.dart';
import '../widgets/pin_input.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen>
    with TickerProviderStateMixin {
  
  int step = 1;
  bool isSaved = false;

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
    if (step < 2) {
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
              AnimatedProgressBar(progress: step / 2),

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
                            "Change PIN",
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

                          // --- STEP 2: NEW PIN ---
                          if (step == 2) ...[
                            const Text(
                              "Enter New PIN",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 20),
                            PINInput(onChanged: (_) {}),
                            const SizedBox(height: 20),
                            const Text(
                              "Re-enter PIN",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 20),
                            PINInput(onChanged: (_) {}),
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
                                    "PIN Changed Successfully",
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
                            text: step == 2 ? "Save PIN" : "Continue",
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
