import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../screens/analytics_screen.dart';

class TrendChart extends StatelessWidget {
  final List<DailyTransactionPoint> data;

  const TrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFED1B2E), Color(0xFFB8132A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFED1B2E).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Transaction Trend",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                titlesData: const FlTitlesData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                        .toList(),
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.white,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: data.map((e) => e.amount).reduce((a, b) => a < b ? a : b) - 50,
                maxY: data.map((e) => e.amount).reduce((a, b) => a > b ? a : b) + 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}