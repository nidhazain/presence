import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/profileapi.dart';
import 'package:presence/src/features/api/employee/shiftapi.dart';
import 'package:presence/src/features/api/hr/hrdashboardapi.dart';

class Hrhome extends StatefulWidget {
  const Hrhome({super.key});

  @override
  HrhomeState createState() => HrhomeState();
}

class HrhomeState extends State<Hrhome> {
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _dashboardData;
  bool _isLoadingDashboard = true;
  List<dynamic> shiftAssignments = [];
  bool _isLoadingShifts = true;

  late String currentDate;
  late String greeting;

  int totalEmployees = 0;
  int onLeaveToday = 0;
  int leaveRequests = 0;
  int attendanceRequests = 0;
  int leaveCancellations = 0;
  int presentToday = 0;
  int absentToday = 0;
  int lateToday = 0;
  List<dynamic> attendanceData = [];
  List<dynamic> weeklyAttendanceData = [];

  String title='morning shift';
  String date = 'march 29';

  @override
  void initState() {
    super.initState();
    _initializeGreeting();
    _fetchProfile();
    _fetchDashboard();
    _fetchShiftAssignments();
  }

   Future<void> _fetchShiftAssignments() async {
    try {
      final data = await ShiftService.fetchShiftAssignments();
      if (mounted) {
        setState(() {
          shiftAssignments = data['assignments'] ?? [];
          _isLoadingShifts = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching shift assignments: $e');
      if (mounted) {
        setState(() {
          _isLoadingShifts = false;
        });
      }
    }
  }


  Future<void> _fetchProfile() async {
    try {
      final data = await ProfileService.fetchProfileData();
      if (mounted) {
        setState(() {
          _profileData = data;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
    }
  }

  Future<void> _fetchDashboard() async {
    try {
      final data = await HrDashboardService.fetchDashboardData();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          // Update dashboard variables using the API response
          totalEmployees = data['total_employees'] != null
              ? (data['total_employees'] as List).length
              : 0;
          onLeaveToday = data['on_leave_today'] ?? 0;
          leaveRequests = data['leave_requests'] ?? 0;
          attendanceRequests = data['attendance_request'] ?? 0;
          leaveCancellations = data['leave_cancellations'] ?? 0;
          presentToday = data['present'] ?? 0;
          absentToday = data['absent'] ?? 0;
          lateToday = data['late'] ?? 0;
          attendanceData = data['attendance_data'] ?? [];
          weeklyAttendanceData = data['weekly_attendance'] ?? [];
          _isLoadingDashboard = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoadingDashboard = false;
        });
      }
    }
  }

  void _initializeGreeting() {
    DateTime now = DateTime.now();
    currentDate = DateFormat('EEEE, MMMM d').format(now);

    int hour = now.hour;
    if (hour < 12) {
      greeting = "Good Morning,";
    } else if (hour < 17) {
      greeting = "Good Afternoon,";
    } else {
      greeting = "Good Evening,";
    }
  }

  List<Map<String, dynamic>> get _statusCardData {
    return [
      {"title": "Total Employees", "subtitle": "$totalEmployees"},
      {"title": "On Leave", "subtitle": "$onLeaveToday"},
      {"title": "Leave Requests", "subtitle": "$leaveRequests"},
      {"title": "Attendance Requests", "subtitle": "$attendanceRequests"},
      if (leaveCancellations > 0)
        {"title": "Leave Cancellations", "subtitle": "$leaveCancellations"},
    ];
  }

  void _showAttendanceDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Today's Attendance Details"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAttendanceSummary(),
                  SizedBox(height: 20),
                  _buildAttendanceList(),
                ],
              ),
            ),
          ),
          actions: [
            CustomButton(
              text: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAttendanceStat("Present", presentToday, purple),
        _buildAttendanceStat("Late", lateToday, blue),
        _buildAttendanceStat("Absent", absentToday, primary),
      ],
    );
  }

  Widget _buildAttendanceStat(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceList() {
    if (attendanceData.isEmpty) {
      return Text("No attendance data available");
    }

    return Column(
      children: [
        Text("Check-in/Check-out Times",
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ...attendanceData
            .map((record) => ListTile(
                  title: Text(record['employee'] ?? 'Unknown'),
                  subtitle: Text(
                      "In: ${record['check_in']} - Out: ${record['check_out']}"),
                ))
            .toList(),
      ],
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    if (weeklyAttendanceData.isEmpty) {
      return List.generate(
          7,
          (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: 0,
                    color: purple,
                    width: 10,
                    borderRadius: BorderRadius.zero,
                  ),
                  BarChartRodData(
                    toY: 0,
                    color: blue,
                    width: 10,
                    borderRadius: BorderRadius.zero,
                  ),
                  BarChartRodData(
                    toY: 0,
                    color: primary,
                    width: 10,
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              ));
    }

    return List.generate(7, (index) {
      final dayData = weeklyAttendanceData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (dayData['present'] ?? 0).toDouble(),
            color: purple,
            width: 10,
          ),
          BarChartRodData(
            toY: (dayData['late'] ?? 0).toDouble(),
            color: blue,
            width: 10,
          ),
          BarChartRodData(
            toY: (dayData['absent'] ?? 0).toDouble(),
            color: primary,
            width: 10,
          ),
        ],
        barsSpace: 4,
      );
    });
  }

  List<String> get _chartDays {
    if (weeklyAttendanceData.isEmpty) {
      return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    }

    return weeklyAttendanceData.map((day) {
      final date = DateTime.parse(day['date']);
      return DateFormat('E').format(date);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoadingDashboard
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(size.width * 0.03),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildGreetingSection(),
                    _buildStatusCards(size),

                    // Today's Attendance Summary
                    GestureDetector(
                      onTap: _showAttendanceDetails,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: CustomCard1(
                          title: "Today's Attendance",
                          subtitle:
                              "Present: $presentToday | Late: $lateToday | Absent: $absentToday",
                          fillColor: Colors.grey[100]!,
                        ),
                      ),
                    ),

                    // Add the color indicators here
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildColorIndicator(purple, "Present"),
                          _buildColorIndicator(blue, "Late"),
                          _buildColorIndicator(primary, "Absent"),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Weekly Attendance Chart
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomTitleText8(text: 'Weekly Attendance'),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: _getBarGroups(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: _calculateChartInterval(),
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    "${value.toInt()}",
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      _chartDays[value.toInt()],
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom:
                                  BorderSide(color: primary.withOpacity(0.5)),
                              left: BorderSide(color: primary.withOpacity(0.5)),
                              right: BorderSide(color: Colors.transparent),
                              top: BorderSide(color: Colors.transparent),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _calculateChartInterval(),
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: primary.withOpacity(0.3),
                                strokeWidth: 1,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

GestureDetector(
  onTap: () {
    if (_isLoadingShifts) return;
    
    // Organize shifts by shift_type
    Map<String, List<dynamic>> shiftsByType = {};
    
    for (var assignment in shiftAssignments) {
      String shiftType = assignment['shift_type'] ?? 'Unknown';
      if (!shiftsByType.containsKey(shiftType)) {
        shiftsByType[shiftType] = [];
      }
      shiftsByType[shiftType]!.add(assignment);
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Today's Shift Assignments"),
          content: Container(
            width: double.maxFinite,
            child: shiftAssignments.isEmpty
                ? Text("No shift assignments for today")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: shiftsByType.length,
                    itemBuilder: (context, index) {
                      String shiftType = shiftsByType.keys.elementAt(index);
                      List<dynamic> employees = shiftsByType[shiftType]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shift heading
                          Padding(
                            padding: EdgeInsets.only(top: index > 0 ? 16 : 0, bottom: 8),
                            child: Text(
                              shiftType,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primary,
                              ),
                            ),
                          ),
                          
                          // Employees or "No employees" message
                          employees.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(left: 8, bottom: 8),
                                  child: Text(
                                    "No employees assigned",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: employees.map((employee) {
                                    return Padding(
                                      padding: EdgeInsets.only(left: 8, bottom: 4),
                                      child: Text(
                                        employee['employee_name'] ?? 'Unknown',
                                      ),
                                    );
                                  }).toList(),
                                ),
                          
                          // Add divider if not the last item
                          if (index < shiftsByType.length - 1)
                            Divider(height: 16),
                        ],
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  },
  child: CustomCard2(
    title: "Today's Shifts",
    subtitle: "${shiftAssignments.length} employees assigned",
  ),
)

                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildColorIndicator(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _calculateChartInterval() {
    if (weeklyAttendanceData.isEmpty) return 10;

    int maxValue = 0;
    for (var day in weeklyAttendanceData) {
      int dayMax = [day['present'] ?? 0, day['late'] ?? 0, day['absent'] ?? 0]
          .reduce((a, b) => a > b ? a : b);
      if (dayMax > maxValue) maxValue = dayMax;
    }

    if (maxValue <= 10) return 2;
    if (maxValue <= 20) return 5;
    if (maxValue <= 50) return 10;
    return 20;
  }

  Widget _buildStatusCards(Size size) {
    // Removed 'const' keyword so that withOpacity works as expected.
    final List<Color> indicatorColors = [
      Color.fromARGB(255, 171, 217, 255).withOpacity(0.3),
      Color.fromARGB(255, 217, 182, 250).withOpacity(0.3),
      Color.fromARGB(255, 200, 242, 156).withOpacity(0.3),
      Color.fromARGB(255, 255, 183, 212).withOpacity(0.3),
    ];

    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: size.height * 0.26,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getResponsiveColumnCount(size),
            crossAxisSpacing: size.width * 0.015,
            mainAxisSpacing: size.height * 0.015,
            childAspectRatio: _calculateChildAspectRatio(size),
          ),
          itemCount: _statusCardData.length,
          itemBuilder: (context, index) {
            return CustomCard1(
              title: _statusCardData[index]["title"] ?? "",
              subtitle: _statusCardData[index]["subtitle"] ?? "",
              fillColor: indicatorColors[index % indicatorColors.length],
            );
          },
        ),
      ),
    );
  }

  int _getResponsiveColumnCount(Size size) {
    if (size.width > 900) return 4;
    if (size.width > 600) return 3;
    return 2;
  }

  double _calculateChildAspectRatio(Size size) {
    return size.width / (size.height * 0.27);
  }

  Widget _buildGreetingSection() {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    CustomTitleText8(
                      text: _profileData?['name'] ?? 'HR Manager',
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: primary),
                    SizedBox(width: 8),
                    Text(
                      currentDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
