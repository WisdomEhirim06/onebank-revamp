import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onebank_revamp/screens/transfer_success_screen.dart';
import '../main.dart';
import '../services/transaction_service.dart';
import '../services/user_session.dart';
import '../models/transaction_model.dart';
import 'receipt_screen.dart';

class TransferConfirmScreen extends StatefulWidget {
  final String recipientName;
  final String accountNumber;
  final String bank;
  final double amount;
  final String? description;

  const TransferConfirmScreen({
    super.key,
    required this.recipientName,
    required this.accountNumber,
    required this.bank,
    required this.amount,
    this.description,
  });

  @override
  State<TransferConfirmScreen> createState() => _TransferConfirmScreenState();
}

class _TransferConfirmScreenState extends State<TransferConfirmScreen>
    with TickerProviderStateMixin {
  bool _pinSubmitted = false;
  final List<TextEditingController> _pinControllers = 
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = 
      List.generate(4, (_) => FocusNode());
  
  late AnimationController _controller;
  late Animation<double> _fade;
  bool _wrongPin = false;
  String _errorMessage = '';

  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 360));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onPinChange(int index, String val) {
    if (val.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    
    // Clear error when user types
    if (_wrongPin) {
      setState(() {
        _wrongPin = false;
        _errorMessage = '';
      });
    }
  }

  String get _enteredPin => _pinControllers.map((c) => c.text).join();

  void _clearPin() {
    for (var controller in _pinControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _submitPin() async {
    if (_enteredPin.length < 4) return;

    // Get user from session
    final user = UserSession().currentUser;
    if (user == null) {
      _showError('User session expired. Please login again.');
      return;
    }

    // Validate PIN against stored PIN
    if (_enteredPin != user.pin) {
      HapticFeedback.mediumImpact();
      setState(() {
        _wrongPin = true;
        _errorMessage = 'Incorrect PIN. Please try again.';
      });
      _clearPin();
      return;
    }

    // PIN is correct - process transfer
    setState(() {
      _pinSubmitted = true;
      _wrongPin = false;
      _errorMessage = '';
    });

    try {
      final result = await _transactionService.createTransfer(
        senderName: user.fullName,
        recipientName: widget.recipientName,
        accountNumber: widget.accountNumber,
        bank: widget.bank,
        amount: widget.amount,
        description: widget.description ?? '',
      );

      if (!mounted) return;

      if (result['success']) {
        final transaction = result['transaction'] as TransactionModel;
        
        // Navigate to receipt screen
        final timestamp = DateTime.now();
        final txnRef = "ONE${timestamp.millisecondsSinceEpoch}"; // Generates a unique ID
        final senderName = UserSession().currentUser?.fullName ?? 'User';

        Navigator.pushAndRemoveUntil(
          context,
          createRoute(TransferSuccessScreen(
            senderName: senderName,
            txnRef: txnRef,
            timestamp: timestamp,
            isInterAccount: false,
            
            recipientName: transaction.recipientName,
            accountNumber: transaction.accountNumber,
            bank: transaction.bank,
            amount: transaction.amount,
            description: transaction.description,
          )),
          (route) => route.isFirst,
        );
      } else {
        setState(() {
          _pinSubmitted = false;
          _wrongPin = true;
          _errorMessage = result['error'] ?? 'Transfer failed';
        });
        _clearPin();
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _pinSubmitted = false;
        _wrongPin = true;
        _errorMessage = 'An error occurred. Please try again.';
      });
      _clearPin();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return !_pinSubmitted;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFFFFF5F6), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  if (!_pinSubmitted)
                                    IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.arrow_back)),
                                  const Spacer()
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text('Confirm Transfer',
                                  style: TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              const Text(
                                'Review transfer details and enter your 4-digit PIN to send the funds.',
                                style: TextStyle(color: Color(0xFF757575)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFED1B2E), Color(0xFFB8132A)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFED1B2E).withOpacity(0.25),
                                      blurRadius: 22,
                                      offset: const Offset(0, 14),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transfer Details',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: .3,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.person_rounded,
                                            color: Colors.white, size: 30),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.recipientName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${widget.bank} • ${widget.accountNumber}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    const Divider(color: Colors.white24, thickness: 1),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Amount',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₦${widget.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (widget.description != null &&
                                        widget.description!.isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      Text(
                                        'Description',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        widget.description!,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // PIN or loader
                              if (!_pinSubmitted)
                                Column(
                                  children: [
                                    const Text(
                                      'Enter your PIN',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(4, (i) {
                                        return _PinBox(
                                          controller: _pinControllers[i],
                                          focusNode: _focusNodes[i],
                                          onChanged: (val) => _onPinChange(i, val),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 12),
                                    if (_wrongPin)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red.shade700,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _errorMessage,
                                                style: TextStyle(
                                                  color: Colors.red.shade700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                )
                              else
                                Column(
                                  children: const [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFED1B2E),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text('Processing transfer...'),
                                  ],
                                ),

                              const Expanded(child: SizedBox()),

                              // bottom buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _pinSubmitted
                                          ? null
                                          : () {
                                              Navigator.pop(context);
                                            },
                                      style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFFED1B2E)),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12))),
                                      child: Text('Cancel',
                                          style: TextStyle(
                                              color: _pinSubmitted
                                                  ? Colors.grey
                                                  : const Color(0xFFED1B2E),
                                              fontSize: 16)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _pinSubmitted ? null : _submitPin,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFED1B2E),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12))),
                                      child: const Text('Confirm & Send',
                                          style: TextStyle(color: Colors.white, fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const _PinBox({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 64,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 6))
          ]),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: true,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: onChanged,
      ),
    );
  }
}