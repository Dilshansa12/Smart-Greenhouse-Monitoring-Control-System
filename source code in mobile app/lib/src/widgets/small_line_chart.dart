import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SmallLineChart extends StatelessWidget {
  final List<double> data;
  final String label;
  final Color color;

  const SmallLineChart({
    super.key,
    required this.data,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i]),
    ];

    // Auto range calculation
    double minY = data.isEmpty ? 0 : data.reduce((a, b) => a < b ? a : b);
    double maxY = data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b);

    double padding = (maxY - minY) * 0.1; // 10% padding
    if (padding == 0) padding = 1;

    minY -= padding;
    maxY += padding;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 4,
                      dotData: FlDotData(show: false),
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 204), // 0.8 opacity ≈ 204/255
                          color.withValues(alpha: 255), // full opacity
                        ],
                      ),
                    ),
                  ],
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: ((maxY - minY) / 4),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            index.toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
