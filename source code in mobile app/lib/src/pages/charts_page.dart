import 'package:flutter/material.dart';
import '../widgets/small_line_chart.dart';

class ChartsPage extends StatelessWidget {
  final List<double> tempData;
  final List<double> humData;
  final List<double> lightData;
  final List<double> gasData;

  const ChartsPage({
    super.key,
    required this.tempData,
    required this.humData,
    required this.lightData,
    required this.gasData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Charts")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SmallLineChart(
              data: tempData,
              label: "Temperature",
              color: Colors.orange,
            ),
            const SizedBox(height: 12),

            SmallLineChart(
              data: humData,
              label: "Humidity",
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

            SmallLineChart(
              data: lightData,
              label: "Light",
              color: Colors.amber,
            ),
            const SizedBox(height: 12),

            SmallLineChart(data: gasData, label: "Gas", color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
