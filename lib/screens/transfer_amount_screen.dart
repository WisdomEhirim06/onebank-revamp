import 'package:flutter/material.dart';
import '../main.dart';
import 'transfer_confirm_screen.dart';

class TransferAmountScreen extends StatefulWidget {
  final String accountNumber;
  final String bank;
  final String recipientName;

  const TransferAmountScreen({
    super.key,
    required this.accountNumber,
    required this.bank,
    required this.recipientName,
  });

  @override
  State<TransferAmountScreen> createState() => _TransferAmountScreenState();
}

class _TransferAmountScreenState extends State<TransferAmountScreen>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 360));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _cancel() {
    Navigator.popUntil(
        context, (route) => route.isFirst || route.settings.name == null);
  }

  void _continue() {
    final amountText = _amountController.text.replaceAll(',', '').trim();
    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Enter a valid amount.')));
      return;
    }
    final amount = double.parse(amountText);
    Navigator.push(
      context,
      createRoute(TransferConfirmScreen(
        recipientName: widget.recipientName,
        accountNumber: widget.accountNumber,
        bank: widget.bank,
        amount: amount,
        description: _descController.text.trim(),
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
                end: Alignment.bottomCenter)),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back)),
                      Spacer()
                    ],
                  ),
                  SizedBox(height: 6),
                  Text('Enter amount',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('How much would you like to send?',
                      style: TextStyle(color: Color(0xFF757575))),
                  SizedBox(height: 18),
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: Offset(0, 6))
                        ]),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFFED1B2E),
                          child: Text(widget.recipientName[0],
                              style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.recipientName,
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text('${widget.bank} • ${widget.accountNumber}',
                                  style: TextStyle(color: Color(0xFF9E9E9E))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (₦)',
                      hintText: '0.00',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'For rent, groceries, etc.',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFFED1B2E)),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text('Back',
                              style: TextStyle(
                                  color: Color(0xFFED1B2E), fontSize: 16)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _continue,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFED1B2E),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text('Continue',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}