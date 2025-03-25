import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/overtimeapi.dart';

class OvertimestatsPage extends StatefulWidget {
  const OvertimestatsPage({super.key});

  @override
  State<OvertimestatsPage> createState() => _OvertimestatsPageState();
}

class _OvertimestatsPageState extends State<OvertimestatsPage> {
  late Future<OvertimeStats> overtimeStatsFuture;
  List<double> overtimeHours = List.filled(12, 0);
  List<double> animatedValues = List.filled(12, 0);
  int? selectedMonth;
  double? selectedHours;

  @override
  void initState() {
    super.initState();
    overtimeStatsFuture = OvertimeService.fetchOvertimeStats();
    overtimeStatsFuture.then((stats) {
      setState(() {
        overtimeHours = List.generate(12, (index) {
          return stats.monthlyOvertime[_getMonthName(index)] ?? 0.0;
        });
        _startAnimation();
      });
    }).catchError((error) {
      debugPrint('Error fetching overtime stats: $error');
    });
  }

  String _getMonthName(int index) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[index];
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        animatedValues = List.from(overtimeHours);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<OvertimeStats>(
        future: overtimeStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          } else {
            return Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTitleText8(text: 'Monthly Overtime Stats'),
                    CustomTitleText4(
                      text: '${DateTime.now().year}',
                    ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.36,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: screenWidth * 1.5,
                          child: Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.05),
                            child: BarChart(
                              BarChartData(
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(
                                    show: true, drawVerticalLine: false),
                                titlesData: FlTitlesData(
                                  topTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: screenWidth * 0.15,
                                      getTitlesWidget: (value, meta) {
                                        return CustomTitleText10(
                                            text: "${value.toInt()} hrs");
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: screenHeight * 0.05,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              top: screenHeight * 0.01),
                                          child: CustomTitleText10(
                                              text: months[value.toInt()]),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: blue.withOpacity(0.7),
                                  ),
                                  touchCallback: (FlTouchEvent event,
                                      BarTouchResponse? response) {
                                    if (response?.spot != null &&
                                        event is FlTapUpEvent) {
                                      setState(() {
                                        selectedMonth = response!
                                            .spot!.touchedBarGroupIndex;
                                        selectedHours =
                                            overtimeHours[selectedMonth!];
                                      });
                                    }
                                  },
                                ),
                                alignment: BarChartAlignment.spaceBetween,
                                maxY: 12,
                                minY: 0,
                                barGroups: _getAnimatedOvertimeData(),
                              ),
                              swapAnimationDuration:
                                  const Duration(milliseconds: 800),
                              swapAnimationCurve: Curves.easeInOut,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    if (selectedMonth != null)
                      CustomCard5(
                        title: months[selectedMonth!],
                        subtitle: '${selectedHours!.toInt()} hrs',
                        icons: const Icon(Icons.bar_chart, size: 50),
                      ),
                    SizedBox(height: screenHeight * 0.01),
                    CustomCard5(
                      title: 'Total Hours',
                      subtitle:
                          '${overtimeHours.reduce((a, b) => a + b).toInt()} hrs',
                      icons: const Icon(Icons.hourglass_bottom, size: 50),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  List<BarChartGroupData> _getAnimatedOvertimeData() {
    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: animatedValues[index],
            color: blue,
            width: 24,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 12,
              color: blue.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
  }
}

class OvertimeStats {
  final Map<String, double> monthlyOvertime;
  final double totalHours;

  OvertimeStats({
    required this.monthlyOvertime,
    required this.totalHours,
  });

  factory OvertimeStats.fromJson(Map<String, dynamic> json) {
    return OvertimeStats(
      monthlyOvertime: (json['monthly_overtime'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
      totalHours: (json['total_hours'] as num).toDouble(),
    );
  }
}
