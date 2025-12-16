import 'package:flutter/material.dart';

class PINInput extends StatefulWidget {
  final Function(String) onChanged;

  const PINInput({Key? key, required this.onChanged}) : super(key: key);

  @override
  _PINInputState createState() => _PINInputState();
}

class _PINInputState extends State<PINInput> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _handleInput(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    String pin = _controllers.map((c) => c.text).join();
    widget.onChanged(pin);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return Container(
          width: 68,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) => _handleInput(index, value),
          ),
        );
      }),
    );
  }
}