import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EmployeeAttendanceGraph extends StatefulWidget {
  const EmployeeAttendanceGraph({Key? key}) : super(key: key);

  @override
  State<EmployeeAttendanceGraph> createState() => _EmployeeAttendanceGraphState();
}

class _EmployeeAttendanceGraphState extends State<EmployeeAttendanceGraph>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<int> presentEmployees = [42, 45, 40, 38, 35, 20, 15];
  final List<int> lateEmployees = [5, 3, 7, 8, 10, 2, 1];
  final List<int> onLeaveEmployees = [3, 2, 3, 4, 5, 28, 34];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Attendance Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLegend(),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 50,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String status = rodIndex == 0
                                ? 'Present'
                                : rodIndex == 1
                                    ? 'Late'
                                    : 'On Leave';
                            return BarTooltipItem(
                              '$status: ${rod.toY.toInt()}',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(days[value.toInt()]),
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 10,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(days.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: presentEmployees[index] * _animation.value,
                              color: Colors.green,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            BarChartRodData(
                              toY: lateEmployees[index] * _animation.value,
                              color: Colors.orange,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            BarChartRodData(
                              toY: onLeaveEmployees[index] * _animation.value,
                              color: Colors.red,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryCards(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _animationController.reset();
          _animationController.forward();
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Replay Animation',
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Present', Colors.green),
        const SizedBox(width: 16),
        _legendItem('Late', Colors.orange),
        const SizedBox(width: 16),
        _legendItem('On Leave', Colors.red),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildSummaryCards() {
    int totalPresent = presentEmployees.reduce((a, b) => a + b);
    int totalLate = lateEmployees.reduce((a, b) => a + b);
    int totalOnLeave = onLeaveEmployees.reduce((a, b) => a + b);
    int totalEmployees = totalPresent + totalLate + totalOnLeave;

    return Row(
      children: [
        _buildSummaryCard('Total Present', totalPresent, totalEmployees, Colors.green),
        _buildSummaryCard('Total Late', totalLate, totalEmployees, Colors.orange),
        _buildSummaryCard('Total On Leave', totalOnLeave, totalEmployees, Colors.red),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int count, int total, Color color) {
    double percentage = (count / total) * 100;
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('$count', style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
              Text('${percentage.toStringAsFixed(1)}%'),
            ],
          ),
        ),
      ),
    );
  }
}
