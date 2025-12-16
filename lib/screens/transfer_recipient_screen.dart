import 'package:flutter/material.dart';
import '../main.dart';
import '../services/transaction_service.dart';
import 'transfer_amount_screen.dart';

class TransferRecipientScreen extends StatefulWidget {
  const TransferRecipientScreen({Key? key}) : super(key: key);

  @override
  State<TransferRecipientScreen> createState() =>
      _TransferRecipientScreenState();
}

class _TransferRecipientScreenState extends State<TransferRecipientScreen>
    with TickerProviderStateMixin {
  final _acctController = TextEditingController();
  String _selectedBank = 'Sterling OneBank';
  bool _loadingLookup = false;
  String _recipientName = '';
  bool _lookupDone = false;
  String _errorMessage = '';

  final TransactionService _transactionService = TransactionService();

  final List<String> banks = [
    'Sterling OneBank',
    'GTBank',
    'Access Bank',
    'Zenith Bank',
    'First Bank',
    'UBA',
    'Fidelity Bank',
  ];

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _acctController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _lookupAccount() async {
    final accountNumber = _acctController.text.trim();

    if (accountNumber.length < 10) {
      setState(() {
        _recipientName = '';
        _lookupDone = false;
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _loadingLookup = true;
      _lookupDone = false;
      _recipientName = '';
      _errorMessage = '';
    });

    // Only lookup if Sterling OneBank is selected
    if (_selectedBank == 'Sterling OneBank') {
      final result = await _transactionService.lookupAccount(accountNumber);

      setState(() {
        _loadingLookup = false;

        if (result['found'] == true) {
          _recipientName = result['recipientName'];
          _lookupDone = true;
          _errorMessage = '';
        } else {
          _recipientName = '';
          _lookupDone = false;
          _errorMessage = result['message'] ?? 'Account not found';
        }
      });
    } else {
      // For external banks, simulate lookup (in production, use bank API)
      await Future.delayed(const Duration(milliseconds: 700));
      setState(() {
        _loadingLookup = false;
        _recipientName = 'External Account Holder';
        _lookupDone = true;
        _errorMessage = '';
      });
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _continue() {
    if (!_lookupDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter account number and verify recipient.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      createRoute(TransferAmountScreen(
        accountNumber: _acctController.text.trim(),
        bank: _selectedBank,
        recipientName: _recipientName,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF5F6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: _cancel,
                          icon: const Icon(Icons.close, color: Color(0xFF1C1C1C))),
                      const Text('New Transfer',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 48)
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter recipient account number and pick the bank. For OneBank accounts, the name will be verified automatically.',
                    style: TextStyle(color: Color(0xFF757575)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Bank Selection
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14)),
                    child: DropdownButton<String>(
                      value: _selectedBank,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: banks
                          .map((b) => DropdownMenuItem<String>(
                                value: b,
                                child: Row(
                                  children: [
                                    if (b == 'Sterling OneBank')
                                      const Icon(Icons.verified,
                                          color: Color(0xFFED1B2E), size: 18),
                                    const SizedBox(width: 8),
                                    Text(b),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedBank = v ?? 'Sterling OneBank';
                          _recipientName = '';
                          _lookupDone = false;
                          _errorMessage = '';
                        });
                        _lookupAccount();
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Account Number Input
                  TextField(
                    controller: _acctController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: 'e.g. 0123456789',
                      labelText: 'Account Number',
                      filled: true,
                      fillColor: Colors.white,
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                    onChanged: (s) {
                      if (s.length == 10) {
                        _lookupAccount();
                      } else {
                        setState(() {
                          _recipientName = '';
                          _lookupDone = false;
                          _errorMessage = '';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  // Loading State
                  if (_loadingLookup)
                    Row(
                      children: const [
                        SizedBox(width: 8),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFED1B2E)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Verifying account...')
                      ],
                    ),

                  // Error Message
                  if (_errorMessage.isNotEmpty && !_loadingLookup)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Success - Show Recipient
                  if (_lookupDone && _recipientName.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.green.shade300,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 6))
                          ]),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _recipientName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_selectedBank • ${_acctController.text}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF9E9E9E)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancel,
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFED1B2E)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: Color(0xFFED1B2E), fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _lookupDone ? _continue : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFED1B2E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('Continue',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}