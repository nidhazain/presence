import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:presence/src/common_pages/attendance_form.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:presence/src/features/modules/employee/attandancedetails.dart';

class Attendancestats extends StatefulWidget {
  const Attendancestats({super.key});

  @override
  _AttendancestatsState createState() => _AttendancestatsState();
}

class _AttendancestatsState extends State<Attendancestats> {
  int? touchedIndex;
  List<Map<String, dynamic>> attendanceData = [];
  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  String selectedMonth = DateTime.now().month == 0 
      ? 'January' 
      : [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ][DateTime.now().month - 1];

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> loadAttendanceStats(String monthName) async {
    print("Fetching data for $monthName..."); 
    final data = await AttendanceService.fetchAttendanceStats(monthName);
  
    if (!mounted) return;
    if (data != null) {
      print("Data fetched: ${data.toString()}"); 
      setState(() {
        attendanceData = [
          {'label': 'Present', 'value': data.present, 'color': purple},
          {'label': 'Late', 'value': data.late, 'color': blue},
          {'label': 'Absent', 'value': data.absent, 'color': primary},
        ];
      });
    } else {
      setState(() {
        attendanceData = [];
      });
    }
  }

  void _fetchAttendanceData() async {
    await loadAttendanceStats(selectedMonth);
  }

  double get totalValue => attendanceData.fold(0, (sum, item) => sum + item['value']);

  String getPercentage(double value) {
    return totalValue == 0 ? '0.0' : ((value / totalValue) * 100).toStringAsFixed(1);
  }

  Future<Map<String, dynamic>> _fetchEmployeeData() async {
    try {
      final url = Uri.parse('$BASE_URL/empattendoverview/');
      await TokenService.ensureAccessToken();
      String? token = await TokenService.getAccessToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load employee data (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching employee data: ${e.toString()}');
    }
  }

  void _navigateToDetailScreen() async {
  print("Navigation initiated"); 
  
  try {
    NavigatorState? navigator = Navigator.of(context);


    navigator.push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    print("Fetching employee details...");
    final employeeData = await _fetchEmployeeData();
    print("Employee details fetched");


    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => AttendanceDetailScreen(
          employee: Employee(
            name: employeeData['employee_details']['name'] ?? 'N/A',
            workDays: employeeData['attendance_summary']['total']?.toInt() ?? 0,
            approvedLeaves: employeeData['approved_leaves']?.toInt() ?? 0,
            totalOvertime: employeeData['total_overtime']?.toString() ?? '0',
          ),
        ),
      ),
    );
  } catch (e) {
    print("Navigation error: $e");
    Navigator.of(context).pop(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to navigate: ${e.toString()}")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTitleText8(text: 'Monthly Attendance Statistics'),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 14),
                      onChanged: (String? newValue) {
                        if (newValue != null && newValue != selectedMonth) {
                          setState(() {
                            selectedMonth = newValue;
                          });
                          _fetchAttendanceData();
                        }
                      },
                      items: months.map<DropdownMenuItem<String>>((String month) {
                        String shortMonth = month.substring(0, 3);
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text(shortMonth),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.04),
            attendanceData.isEmpty
                ? Center(
                    child: Text(
                      'No data available for the selected month.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque, 
                              onTap: _navigateToDetailScreen,
                              child: PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                      if (!mounted) return;
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        setState(() => touchedIndex = -1);
                                        return;
                                      }
                                      setState(() {
                                        touchedIndex = pieTouchResponse
                                            .touchedSection!
                                            .touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: screenWidth * 0.15,
                                  sections: List.generate(attendanceData.length, (index) {
                                    final data = attendanceData[index];
                                    final double percentValue = totalValue == 0 
                                        ? 0 
                                        : (data['value'] / totalValue) * 100;
                                    return PieChartSectionData(
                                      value: data['value'].toDouble(),
                                      title: '${percentValue.toStringAsFixed(1)}%',
                                      titleStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2)],
                                      ),
                                      color: data['color'],
                                    );
                                  }),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  totalValue.toInt().toString(),
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const Text('Total Days', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Column(
                          children: attendanceData.map((data) {
                            final percentage = getPercentage(data['value'].toDouble());
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: data['color'],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(data['label'], style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ),
                                  Text('${data['value']} (${percentage}%)', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  CustomButton(text: 'View Attendance', onPressed: _navigateToDetailScreen),
            SizedBox(height: screenHeight * 0.01),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Request Attendance',
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => RequestAttendanceDialog(),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}

class AttendanceStats {
  final String month;
  final int year;
  final int totalDays;
  final int present;
  final double presentPercentage;
  final int late;
  final double latePercentage;
  final int absent;
  final double absentPercentage;

  AttendanceStats({
    required this.month,
    required this.year,
    required this.totalDays,
    required this.present,
    required this.presentPercentage,
    required this.late,
    required this.latePercentage,
    required this.absent,
    required this.absentPercentage,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      month: json['month'],
      year: json['year'],
      totalDays: json['total_days'],
      present: json['attendance_statistics']['present']['count'],
      presentPercentage: json['attendance_statistics']['present']['percentage'],
      late: json['attendance_statistics']['late']['count'],
      latePercentage: json['attendance_statistics']['late']['percentage'],
      absent: json['attendance_statistics']['absent']['count'],
      absentPercentage: json['attendance_statistics']['absent']['percentage'],
    );
  }
}