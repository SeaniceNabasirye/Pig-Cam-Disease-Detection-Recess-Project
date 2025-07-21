import 'package:flutter/material.dart';
import 'package:pigcam2/components/common_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int healthyPigs = 75;
  int sickPigs = 25;
  bool showPieChart = true;

  void _showSectionDetails(String label, int value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: Text('Count: $value'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateData() {
    setState(() {
      // For demo: swap values
      final temp = healthyPigs;
      healthyPigs = sickPigs;
      sickPigs = temp;
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {}); // For demo, just rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Chart Page', showBackButton: true),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Pig Health Distribution',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showPieChart = !showPieChart;
                        });
                      },
                      child: Text(showPieChart ? 'Show Bar Chart' : 'Show Pie Chart'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _updateData,
                      child: const Text('Update Data'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.2, // Slightly wider for a larger chart
                      child: showPieChart
                          ? PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: healthyPigs.toDouble(),
                                    title: '$healthyPigs%',
                                    radius: 80, // Increased radius
                                    titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                    badgeWidget: GestureDetector(
                                      onTap: () => _showSectionDetails('Healthy Pigs', healthyPigs),
                                      child: const SizedBox(width: 120, height: 120),
                                    ),
                                    badgePositionPercentageOffset: .98,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red,
                                    value: sickPigs.toDouble(),
                                    title: '$sickPigs%',
                                    radius: 80, // Increased radius
                                    titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                    badgeWidget: GestureDetector(
                                      onTap: () => _showSectionDetails('Sick Pigs', sickPigs),
                                      child: const SizedBox(width: 120, height: 120),
                                    ),
                                    badgePositionPercentageOffset: .98,
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: 60, // Increased center space
                                borderData: FlBorderData(show: false),
                              ),
                            )
                          : BarChart(
                              BarChartData(
                                barGroups: [
                                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: healthyPigs.toDouble(), color: Colors.green)]),
                                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: sickPigs.toDouble(), color: Colors.red)]),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        switch (value.toInt()) {
                                          case 0:
                                            return const Text('Healthy');
                                          case 1:
                                            return const Text('Sick');
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 16,
                  height: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                const Text('Healthy Pigs'),
                const SizedBox(width: 16),
                Container(
                  width: 16,
                  height: 16,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                const Text('Sick Pigs'),
              ],
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }
} 