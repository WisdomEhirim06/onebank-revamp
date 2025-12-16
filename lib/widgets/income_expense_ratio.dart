import 'package:flutter/material.dart';

class IncomeExpenseRatio extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpenseRatio({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    final incomeRatio = total == 0 ? 0.5 : income / total; // helps fallback in a 50/50 split

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Income vs Expense",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Income",
                      style: TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₦${income.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Expense",
                      style: TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₦${expense.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFED1B2E),
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEF0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: incomeRatio.clamp(0.0, 1.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            
          ),
        ],
      ),
    );
  }
}
