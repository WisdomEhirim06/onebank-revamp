import 'package:flutter/material.dart';

class AnimatedInputField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final Function(String) onChanged;

  const AnimatedInputField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    required this.onChanged,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1C)),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              obscureText: widget.isPassword,
              onChanged: widget.onChanged,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}