import 'package:flutter/material.dart';

class InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InsightCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFED1B2E).withOpacity(0.15),
                  const Color(0xFFED1B2E).withOpacity(0.08),
                ],
              ),
        
            ),
            child: Icon(icon, size: 24, color: const Color(0xFFED1B2E),),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),),

              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
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
