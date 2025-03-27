import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/dashboardapi.dart';
import 'package:presence/src/features/api/employee/profileapi.dart';
import 'package:presence/src/features/api/employee/shiftapi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<DashboardData> dashboardData;
  Map<String, dynamic>? _profileData;

  // New shift-related variables
  String shiftTitle = 'Loading Shift...';
  String shiftSubtitle = '';
  List<String> shiftColleagues = [];

  late String currentDate;
  late String greeting;

  double attendancePercentage = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _initializeGreeting();
    _fetchShiftData();
    _fetchShiftColleagues();

  Future.delayed(const Duration(milliseconds: 500), () {
  if (mounted) {
    setState(() {
      attendancePercentage = 70;
    });
  }
});

    dashboardData =
        DashboardService.fetchDashboardData() as Future<DashboardData>;
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

  // Fetch today's shift data
 Future<void> _fetchShiftData() async {
  try {
    final List<dynamic> data = await ShiftService.fetchShiftData();
    final Map<String, dynamic> shiftData =
        data.isNotEmpty ? Map<String, dynamic>.from(data[0]) : {};

    if (mounted) {
      setState(() {
        shiftTitle = shiftData['shift_type'] ?? 'No Shift Assigned';
        final dateStr = shiftData['date'] ?? '';
        DateTime? parsedDate = DateTime.tryParse(dateStr);

        if (parsedDate != null) {
          shiftSubtitle = DateFormat('MMM d, yyyy').format(parsedDate);
        } else if (dateStr.isEmpty) {
          // No date from API? Show today’s date.
          shiftSubtitle = DateFormat('MMM d, yyyy').format(DateTime.now());
        } else {
          // If backend sends junk, fallback to showing whatever was there
          shiftSubtitle = dateStr;
        }
      });
    }
  } catch (e) {
    debugPrint('Error fetching shift data: $e');
    if (mounted) {
      setState(() {
        shiftTitle = 'Error Loading Shift';
      });
    }
  }
}




  // Fetch colleagues assigned to the same shift
Future<void> _fetchShiftColleagues() async {
  try {
    final colleagues = await ShiftService.fetchShiftColleagues();
    if (mounted) {
      setState(() {
        shiftColleagues = colleagues;
      });
    }
  } catch (e) {
    debugPrint('Error fetching shift colleagues: $e');
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

  void _showColleaguesPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: CustomTitleText3(text: shiftTitle),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: shiftColleagues.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: shiftColleagues.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: CustomTitleText9(text: shiftColleagues[index]),
                      );
                    },
                  )
                : const Text('No colleagues assigned for this shift.'),
          ),
          actions: [
            CustomButton(
              text: 'Close',
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FutureBuilder<DashboardData>(
      future: dashboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          attendancePercentage = data.attendancePercentage;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingSection(),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size.width > 600 ? 3 : 2,
                        crossAxisSpacing: size.width * 0.015,
                        mainAxisSpacing: size.height * 0.015,
                        childAspectRatio: size.width / (size.height * 0.3),
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final titles = [
                          "Check-in",
                          "Check-out",
                          "Status",
                          "Overtime"
                        ];
                        final values = [
                          data.checkIn,
                          data.checkOut,
                          data.late ? "Late" : "On Time",
                          data.overtimeToday,
                        ];
                        return CustomCard(
                          title: titles[index],
                          subtitle: values[index],
                          icon: [
                            Icons.login,
                            Icons.logout,
                            Icons.timer_outlined,
                            Icons.access_time,
                          ][index],
                          fillColor: [
                            const Color.fromARGB(255, 171, 217, 255)
                                .withOpacity(.3),
                            const Color.fromARGB(255, 217, 182, 250)
                                .withOpacity(.3),
                            const Color.fromARGB(255, 200, 242, 156)
                                .withOpacity(.3),
                            const Color.fromARGB(255, 255, 183, 212)
                                .withOpacity(.3),
                          ][index],
                        );
                      },
                    ),
                    SizedBox(height: size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomTitleText8(text: 'Attendance Percentage'),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SizedBox(
                      height: size.height * 0.26,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: attendancePercentage),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                            builder: (context, value, _) {
                              return PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: size.width * 0.2,
                                  sections: [
                                    PieChartSectionData(
                                      value: value,
                                      title: '',
                                      showTitle: false,
                                      radius: size.width * 0.05,
                                      color: purple,
                                    ),
                                    PieChartSectionData(
                                      value: 100 - value,
                                      title: '',
                                      showTitle: false,
                                      radius: size.width * 0.05,
                                      color: purple.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: attendancePercentage),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                            builder: (context, value, _) {
                              return CustomTitleText3(
                                  text: '${value.toInt()}%');
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    // Shift card using fetched shift data
                    GestureDetector(
                      onTap: _showColleaguesPopup,
                      child: CustomCard2(
                        title: shiftTitle,
                        subtitle: shiftSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: Text('No data found!'));
        }
      },
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
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
                    const SizedBox(height: 5),
                    CustomTitleText8(
                      text: _profileData?['name'] ?? 'User',
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentDate,
                      style: const TextStyle(
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

class DashboardData {
  final String checkIn;
  final String checkOut;
  final bool late;
  final String overtimeToday;
  final String totalOvertime;
  final double attendancePercentage;
  final String date;
  final List<Map<String, dynamic>> attendanceGraphData;

  DashboardData({
    required this.checkIn,
    required this.checkOut,
    required this.late,
    required this.overtimeToday,
    required this.totalOvertime,
    required this.attendancePercentage,
    required this.date,
    required this.attendanceGraphData,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      late: json['late'],
      overtimeToday: json['overtime_today'],
      totalOvertime: json['total_overtime'],
      attendancePercentage: (json['attendance_percentage'] as num).toDouble(),
      date: json['date'],
      attendanceGraphData:
          List<Map<String, dynamic>>.from(json['attendance_graph_data']),
    );
  }
}
