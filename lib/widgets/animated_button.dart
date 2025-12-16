import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: widget.isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFFED1B2E), Color(0xFFB8132A)])
              : null,
          color: widget.isPrimary ? null : Colors.white,
          border: widget.isPrimary
              ? null
              : Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.isPrimary
                        ? const Color(0xFFED1B2E).withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isPrimary ? Colors.white : const Color(0xFFED1B2E),
            ),
          ),
        ),
      ),
    );
  }
}