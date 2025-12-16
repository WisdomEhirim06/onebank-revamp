import 'package:flutter/material.dart';

class OTPInput extends StatefulWidget {
  final Function(String) onChanged;
  const OTPInput({super.key, required this.onChanged});

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  final List<TextEditingController> _controllers = 
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = 
      List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    // Collect all digits
    String otp = _controllers.map((c) => c.text).join();
    widget.onChanged(otp);

    // Move to next field if digit entered
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onBackspace(String value, int index) {
    // Move to previous field if backspace on empty field
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
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
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            onChanged: (val) {
              _onChanged(val, index);
              _onBackspace(val, index);
            },
          ),
        );
      }),
    );
  }
}