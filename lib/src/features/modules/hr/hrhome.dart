// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:presence/src/common_widget/custom_card.dart';
// import 'package:presence/src/common_widget/submitbutton.dart';
// import 'package:presence/src/common_widget/text_tile.dart';
// import 'package:presence/src/constants/colors.dart';
// import 'package:presence/src/features/api/employee/profileapi.dart';

// class Hrhome extends StatefulWidget {
//   const Hrhome({super.key});

//   @override
//   HrhomeState createState() => HrhomeState();
// }

// class HrhomeState extends State<Hrhome> {
//     Map<String, dynamic>? _profileData;
//   String userName = "Nidha"; // This should be fetched from your user data
//   late String currentDate;
//   late String greeting;

//   double attendancePercentage = 0;
//   String title = 'Shift';
//   String subtitle = 'Jan 20';

//   @override
//   void initState() {
//     super.initState();
//     _initializeGreeting();
//     _fetchProfile();
//   }

//    Future<void> _fetchProfile() async {
//     try {
//       final data = await ProfileService.fetchProfileData();
//       if (mounted) {
//         setState(() {
//           _profileData = data;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching profile data: $e');
//     }
//   }

//   void _initializeGreeting() {
//     // Format current date: "Monday, March 15"
//     DateTime now = DateTime.now();
//     currentDate = DateFormat('EEEE, MMMM d').format(now);

//     // Set greeting based on time of day
//     int hour = now.hour;
//     if (hour < 12) {
//       greeting = "Good Morning,";
//     } else if (hour < 17) {
//       greeting = "Good Afternoon,";
//     } else {
//       greeting = "Good Evening,";
//     }
//   }

//   List<String> colleagues = [
//     "John Doe",
//     "Jane Smith",
//     "Emily Johnson",
//     "Michael Brown"
//   ];

//   final List<Map<String, dynamic>> _statusCardData = [
//     {"title": "Total Employees", "subtitle": "200"},
//     {"title": "On Leave", "subtitle": "05"},
//     {"title": "Leave Requests", "subtitle": "04"},
//     {"title": "Attendance Requests", "subtitle": "01"}
//   ];

//   final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
//   final List<int> present = [40, 40, 38, 30, 39, 37, 35];
//   final List<int> late = [5, 3, 6, 4, 5, 7, 8];
//   final List<int> leave = [5, 5, 6, 5, 6, 6, 7];

//   void _showColleaguesPopup() {
//     Map<String, List<String>> shifts = {
//       "Morning Shift": [
//         "John Doe",
//         "Jane Smith",
//         "Emily Johnson",
//         "Michael Brown"
//       ],
//       "Intermediate Shift": ["Alice Green", "Bob White", "Charlie Black"],
//       "Night Shift": [
//         "John Doe",
//         "Jane Smith",
//         "Emily Johnson",
//         "Michael Brown"
//       ],
//     };

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           content: SizedBox(
//             width: MediaQuery.of(context).size.width * 0.8,
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: shifts.keys.map((shift) {
//                   return ExpansionTile(
//                     title: CustomTitleText8(text: shift),
//                     children: shifts[shift]!.map((colleague) {
//                       return ListTile(
//                         title: CustomTitleText9(text: colleague),
//                       );
//                     }).toList(),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//           actions: [
//             CustomButton(
//               text: 'Close',
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     int totalEmployees = 50; // Adjust this as per your total count

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: EdgeInsets.all(size.width * 0.03),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildGreetingSection(),
//               _buildStatusCards(size),
//               // Attendance Percentage Label
//               Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: CustomTitleText8(text: 'Attendance Percentage'),
//                 ),
//               ),

//               SizedBox(height: size.height * 0.01),

//               // Color Indicator Row
//               Wrap(
//                 spacing: 10, // Space between indicators
//                 runSpacing: 10, // Space when wrapping to next line
//                 alignment: WrapAlignment.center,
//                 children: [
//                   _buildIndicator(purple, "Present",
//                       _calculatePercentage(present, totalEmployees)),
//                   _buildIndicator(
//                       blue, "Late", _calculatePercentage(late, totalEmployees)),
//                   _buildIndicator(primary, "Leave",
//                       _calculatePercentage(leave, totalEmployees)),
//                 ],
//               ),

//               SizedBox(height: size.height * 0.02),

//               // Bar Chart
//               SizedBox(
//                 height: 150,
//                 child: BarChart(
//                   BarChartData(
//                     barGroups: _getBarGroups(),
//                     titlesData: FlTitlesData(
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           interval: 10,
//                           reservedSize: 30,
//                           getTitlesWidget: (value, meta) {
//                             return Text(
//                               "${value.toInt()}",
//                               style: TextStyle(
//                                 color: primary,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, meta) {
//                             return SideTitleWidget(
//                               axisSide: meta.axisSide,
//                               child: Text(
//                                 days[value.toInt()],
//                                 style: TextStyle(
//                                   color: primary,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       topTitles:
//                           AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       rightTitles:
//                           AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     ),
//                     borderData: FlBorderData(
//                       show: true,
//                       border: Border(
//                         bottom: BorderSide(
//                           color: primary.withOpacity(.5),
//                           width: 2,
//                         ),
//                         left: BorderSide(
//                           color: primary.withOpacity(.5),
//                           width: 2,
//                         ),
//                         right: BorderSide(color: Colors.transparent),
//                         top: BorderSide(color: Colors.transparent),
//                       ),
//                     ),
//                     gridData: FlGridData(
//                       show: true,
//                       drawVerticalLine: false,
//                       horizontalInterval: 10,
//                       getDrawingHorizontalLine: (value) {
//                         return FlLine(
//                           color: primary.withOpacity(.3),
//                           strokeWidth: 1,
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: size.height * 0.03),

//               // Shift Card
//               GestureDetector(
//                 onTap: _showColleaguesPopup,
//                 child: Padding(
//                   padding: const EdgeInsets.all(5.0),
//                   child: CustomCard2(title: title, subtitle: subtitle),
//                 ),
//               ),
//               SizedBox(height: size.height * 0.03),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusCards(Size size) {
    
//     final List<Color> indicatorColors = [
//       const Color.fromARGB(255, 171, 217, 255).withOpacity(.3),
//       const Color.fromARGB(255, 217, 182, 250).withOpacity(.3),
//       const Color.fromARGB(255, 200, 242, 156).withOpacity(.3),
//       const Color.fromARGB(255, 255, 183, 212).withOpacity(.3),
//     ];
//     return Padding(
//       padding: const EdgeInsets.all(5),
//       child: SizedBox(
//         height: size.height * 0.26,
//         child: GridView.builder(
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: _getResponsiveColumnCount(size),
//             crossAxisSpacing: size.width * 0.015,
//             mainAxisSpacing: size.height * 0.015,
//             childAspectRatio: _calculateChildAspectRatio(size),
//           ),
//           itemCount: _statusCardData.length,
//           itemBuilder: (context, index) {
//             return CustomCard1(
//               title: _statusCardData[index]["title"] ?? "",
//               subtitle: _statusCardData[index]["subtitle"] ?? "",
//               fillColor: indicatorColors[index % indicatorColors.length],
//               // Assign colors cyclically
//             );
//           },
//         ),
//       ),
//     );
//   }

// // Helper function for color indicators
//   Widget _buildIndicator(Color color, String label, String percentage) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
//         ],
//         border: Border.all(color: color, width: 2),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min, // Makes it adjust dynamically
//         children: [
//           Container(
//             width: 14,
//             height: 14,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//           SizedBox(width: 6),
//           Flexible(
//             child: CustomTitleText9(
//               text: "$label ($percentage)",
//               //overflow: TextOverflow.ellipsis, // Prevents text overflow
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// // Function to calculate percentage
//   String _calculatePercentage(List<int> values, int totalEmployees) {
//     int total = values.reduce((sum, val) => sum + val);
//     double percentage = (total / (totalEmployees * values.length)) * 100;
//     return "${percentage.toStringAsFixed(1)}%";
//   }

//  List<BarChartGroupData> _getBarGroups() {
//   return List.generate(days.length, (index) {
//     return BarChartGroupData(
//       x: index,
//       barRods: [
//         BarChartRodData(
//           toY: present[index].toDouble(), 
//           color: purple, 
//           width: 10,
//           borderRadius: BorderRadius.zero, 
//         ),
//         BarChartRodData(
//           toY: late[index].toDouble(), 
//           color: blue, 
//           width: 10,
//           borderRadius: BorderRadius.zero, 
//         ),
//         BarChartRodData(
//           toY: leave[index].toDouble(), 
//           color: primary, 
//           width: 10,
//           borderRadius: BorderRadius.zero, 
//         ),
//       ],
//       barsSpace: 4, 
//     );
//   });
// }
//   /// Returns appropriate column count based on screen width
//   int _getResponsiveColumnCount(Size size) {
//     if (size.width > 900) return 4; // Large screens
//     if (size.width > 600) return 3; // Medium screens
//     return 2; // Small screens
//   }

//   /// Calculates the aspect ratio for grid items based on screen size
//   double _calculateChildAspectRatio(Size size) {
//     // Adjust this formula based on your design needs
//     return size.width / (size.height * 0.27);
//   }

// Widget _buildGreetingSection() {
//     return Container(
//       margin: EdgeInsets.only(top: 8, bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       greeting,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     CustomTitleText8(
//                         text: _profileData?['name'] ?? 'Name Not Found',
//                       ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.calendar_today,
//                       size: 18,
//                       color: primary,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       currentDate,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;  // For API calls
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/profileapi.dart';
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
  
  String userName = "Nidha"; // This should be fetched from your user data
  late String currentDate;
  late String greeting;

  // Dashboard variables
  int totalEmployees = 0;
  int onLeaveToday = 0;
  int leaveRequests = 0;
  int attendanceRequests = 0;
  int leaveCancellations = 0;
  int present = 0;
  int absent = 0;
  int late = 0;
  List<dynamic> attendanceData = [];

  // Variables for static chart data (replace with dynamic values if available)
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final List<int> presentChart = [40, 40, 38, 30, 39, 37, 35];
  final List<int> lateChart = [5, 3, 6, 4, 5, 7, 8];
  final List<int> leaveChart = [5, 5, 6, 5, 6, 6, 7];

  String title = 'Shift';
  String subtitle = 'Jan 20';

  @override
  void initState() {
    super.initState();
    _initializeGreeting();
    _fetchProfile();
    _fetchDashboard();
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
      // Replace with your actual JWT token retrieval logic.
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
          present = data['present'] ?? 0;
          absent = data['absent'] ?? 0;
          late = data['late'] ?? 0;
          attendanceData = data['attendance_data'] ?? [];
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
    // Format current date: "Monday, March 15"
    DateTime now = DateTime.now();
    currentDate = DateFormat('EEEE, MMMM d').format(now);

    // Set greeting based on time of day
    int hour = now.hour;
    if (hour < 12) {
      greeting = "Good Morning,";
    } else if (hour < 17) {
      greeting = "Good Afternoon,";
    } else {
      greeting = "Good Evening,";
    }
  }

  List<String> colleagues = [
    "John Doe",
    "Jane Smith",
    "Emily Johnson",
    "Michael Brown"
  ];

  // Generate status card data from dashboard variables
  List<Map<String, dynamic>> get _statusCardData {
    return [
      {"title": "Total Employees", "subtitle": "$totalEmployees"},
      {"title": "On Leave", "subtitle": onLeaveToday.toString()},
      {"title": "Leave Requests", "subtitle": leaveRequests.toString()},
      {"title": "Attendance Requests", "subtitle": attendanceRequests.toString()},
    ];
  }

  void _showColleaguesPopup() {
    Map<String, List<String>> shifts = {
      "Morning Shift": [
        "John Doe",
        "Jane Smith",
        "Emily Johnson",
        "Michael Brown"
      ],
      "Intermediate Shift": ["Alice Green", "Bob White", "Charlie Black"],
      "Night Shift": [
        "John Doe",
        "Jane Smith",
        "Emily Johnson",
        "Michael Brown"
      ],
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: shifts.keys.map((shift) {
                  return ExpansionTile(
                    title: CustomTitleText8(text: shift),
                    children: shifts[shift]!.map((colleague) {
                      return ListTile(
                        title: CustomTitleText9(text: colleague),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            CustomButton(
              text: 'Close',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
                    // Attendance Percentage Label
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomTitleText8(text: 'Attendance Percentage'),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Color Indicator Row
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildIndicator(
                          purple,
                          "Present",
                          _calculatePercentage(presentChart, totalEmployees),
                        ),
                        _buildIndicator(
                          blue,
                          "Late",
                          _calculatePercentage(lateChart, totalEmployees),
                        ),
                        _buildIndicator(
                          primary,
                          "Leave",
                          _calculatePercentage(leaveChart, totalEmployees),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    // Bar Chart
                    SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          barGroups: _getBarGroups(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 10,
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
                                      days[value.toInt()],
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
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color: primary.withOpacity(.5),
                                width: 2,
                              ),
                              left: BorderSide(
                                color: primary.withOpacity(.5),
                                width: 2,
                              ),
                              right: BorderSide(color: Colors.transparent),
                              top: BorderSide(color: Colors.transparent),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 10,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: primary.withOpacity(.3),
                                strokeWidth: 1,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    // Shift Card
                    GestureDetector(
                      onTap: _showColleaguesPopup,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: CustomCard2(title: title, subtitle: subtitle),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCards(Size size) {
    final List<Color> indicatorColors = [
      const Color.fromARGB(255, 171, 217, 255).withOpacity(.3),
      const Color.fromARGB(255, 217, 182, 250).withOpacity(.3),
      const Color.fromARGB(255, 200, 242, 156).withOpacity(.3),
      const Color.fromARGB(255, 255, 183, 212).withOpacity(.3),
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

  Widget _buildIndicator(Color color, String label, String percentage) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 6),
          Flexible(
            child: CustomTitleText9(
              text: "$label ($percentage)",
            ),
          ),
        ],
      ),
    );
  }

  String _calculatePercentage(List<int> values, int totalEmployees) {
    int total = values.reduce((sum, val) => sum + val);
    double percentage = (total / (totalEmployees * values.length)) * 100;
    return "${percentage.toStringAsFixed(1)}%";
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(days.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: presentChart[index].toDouble(),
            color: purple,
            width: 10,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: lateChart[index].toDouble(),
            color: blue,
            width: 10,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: leaveChart[index].toDouble(),
            color: primary,
            width: 10,
            borderRadius: BorderRadius.zero,
          ),
        ],
        barsSpace: 4,
      );
    });
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
                      text: _profileData?['name'] ?? 'Name Not Found',
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
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: primary,
                    ),
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
