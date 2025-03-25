// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:presence/src/common_pages/leaveform.dart';
// import 'package:presence/src/common_widget/custom_card.dart';
// import 'package:presence/src/common_widget/submitbutton.dart';
// import 'package:presence/src/common_widget/text_tile.dart';
// import 'package:presence/src/constants/colors.dart';
// import 'package:presence/src/features/modules/hr/hrselfleaverequest.dart';

// class Hrselfportal extends StatefulWidget {
//   const Hrselfportal({super.key});

//   @override
//   State<Hrselfportal> createState() => _HrselfportalState();
// }

// class _HrselfportalState extends State<Hrselfportal> {
//   // Employee attendance percentage
//   double _attendancePercentage = 0;
  
//   // Status card data for easy maintenance
//   final List<Map<String, dynamic>> _statusCardData= [
//     {"title": "Check-in", "subtitle": "09:00 am","icon": Icons.login,},
//     {"title": "Check-out", "subtitle": "06:00 pm","icon": Icons.logout,},
//     {"title": "Late", "subtitle": "8 min","icon": Icons.timer,},
//     {"title": "Overtime", "subtitle": "2 hrs","icon": Icons.access_time,}
//   ];
  

//   @override
//   void initState() {
//     super.initState();
//     _loadAttendanceData();
//   }
  
//   /// Simulates loading attendance data from a backend service
//   Future<void> _loadAttendanceData() async {
//     // In a real app, this would be an API call
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     if (mounted) {
//       setState(() {
//         _attendancePercentage = 70;
//       });
//     }
//   }
  
//   /// Handles leave request action
//   void _handleLeaveRequest(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Dialog(
//         child: LeaveForm(),
//       );
//     },
//   );
// }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: _buildMainContent(context),
//     );
//   }
  
//   Widget _buildMainContent(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final padding = size.width * 0.03;
    
//     return Padding(
//       padding: EdgeInsets.all(padding),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: size.height * 0.01),
//             _buildStatusCards(size),
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: CustomTitleText8(text: 'Attendance Percentage'),
//             ),
//             SizedBox(height: size.height * 0.02),
//             _buildAttendanceChart(size),
//             SizedBox(height: size.height * 0.05),
//             CustomButton(
//               text: 'Request Leave', 
//               onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=> HRLeaveRequestPage())),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildStatusCards(Size size) {
//       final List<Color> indicatorColors = [
//       const Color.fromARGB(255, 171, 217, 255).withOpacity(.3),
//       const Color.fromARGB(255, 217, 182, 250).withOpacity(.3),
//       const Color.fromARGB(255, 200, 242, 156).withOpacity(.3),
//       const Color.fromARGB(255, 255, 183, 212).withOpacity(.3),
//     ];
//     return SizedBox(
//       height: size.height * 0.3,
//       child: GridView.builder(
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: _getResponsiveColumnCount(size),
//           crossAxisSpacing: size.width * 0.015,
//           mainAxisSpacing: size.height * 0.015,
//           childAspectRatio: _calculateChildAspectRatio(size),
//         ),
//         itemCount: _statusCardData.length,
//         itemBuilder: (context, index) {
//           return CustomCard(
//   title: _statusCardData[index]["title"] ?? "",
//   subtitle: _statusCardData[index]["subtitle"] ?? "",
//   icon: _statusCardData[index]["icon"] ?? Icons.help_outline,
//   fillColor: indicatorColors[index % indicatorColors.length],

// );
//         },
//       ),
//     );
//   }
  
//   Widget _buildAttendanceChart(Size size) {
//     return SizedBox(
//       height: size.height * 0.26,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           TweenAnimationBuilder<double>(
//             tween: Tween(begin: 0, end: _attendancePercentage),
//             duration: const Duration(seconds: 2),
//             curve: Curves.easeInOut,
//             builder: (context, value, _) {
//               return PieChart(
//                 PieChartData(
//                   sectionsSpace: 0,
//                   centerSpaceRadius: size.width * 0.2,
//                   sections: _buildPieChartSections(value, size),
//                 ),
//               );
//             },
//           ),
//           TweenAnimationBuilder<double>(
//             tween: Tween(begin: 0, end: _attendancePercentage),
//             duration: const Duration(seconds: 2),
//             curve: Curves.easeInOut,
//             builder: (context, value, _) {
//               return CustomTitleText3(text: '${value.toInt()}%');
//             },
//           ),
//         ],
//       ),
//     );
//   }
  
//   List<PieChartSectionData> _buildPieChartSections(double value, Size size) {
//     return [
//       PieChartSectionData(
//         value: value,
//         title: '',
//         showTitle: false,
//         radius: size.width * 0.05,
//         color: purple,
//       ),
//       PieChartSectionData(
//         value: 100 - value,
//         title: '',
//         showTitle: false,
//         radius: size.width * 0.05,
//         color: purple.withOpacity(0.3),
//       ),
//     ];
//   }
  
//   /// Returns appropriate column count based on screen width
//   int _getResponsiveColumnCount(Size size) {
//     if (size.width > 900) return 4; // Large screens
//     if (size.width > 600) return 3; // Medium screens
//     return 2; // Small screens
//   }
  
//   /// Calculates the aspect ratio for grid items based on screen size
//   double _calculateChildAspectRatio(Size size) {
//     // Adjust this formula based on your design needs
//     return size.width / (size.height * 0.3);
//   }
// }

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:presence/src/common_pages/leaveform.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:presence/src/features/modules/hr/hrselfleaverequest.dart';

class Hrselfportal extends StatefulWidget {
  const Hrselfportal({super.key});

  @override
  State<Hrselfportal> createState() => _HrselfportalState();
}

class _HrselfportalState extends State<Hrselfportal> {
  double _attendancePercentage = 0;
  String _checkInTime = "-";
  String _checkOutTime = "-";
  String _lateDays = "0";
  String _overtimeHours = "0";

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    await TokenService.ensureAccessToken();
    String? token = await TokenService.getAccessToken();
    final response = await http.get(
      Uri.parse('$BASE_URL/hr/attendance-stats/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _attendancePercentage = data['attendance_percentage']?.toDouble() ?? 0;
        _checkInTime = data['check_in'] ?? "-";
        _checkOutTime = data['check_out'] ?? "-";
        _lateDays = data['late_days'].toString();
        _overtimeHours = data['total_overtime_hours'].toString();
      });
    } else {
      // Handle error
      print("Failed to load attendance data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildMainContent(context),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.03;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.01),
            _buildStatusCards(size),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CustomTitleText8(text: 'Attendance Percentage'),
            ),
            SizedBox(height: size.height * 0.02),
            _buildAttendanceChart(size),
            SizedBox(height: size.height * 0.05),
            CustomButton(
              text: 'Request Leave',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => HRLeaveRequestPage())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCards(Size size) {
    final List<Map<String, dynamic>> statusCardData = [
      {"title": "Check-in", "subtitle": _checkInTime, "icon": Icons.login},
      {"title": "Check-out", "subtitle": _checkOutTime, "icon": Icons.logout},
      {"title": "Late Days", "subtitle": _lateDays, "icon": Icons.timer},
      {"title": "Overtime", "subtitle": "$_overtimeHours hrs", "icon": Icons.access_time},
    ];

    final List<Color> indicatorColors = [
      const Color.fromARGB(255, 171, 217, 255).withOpacity(.3),
      const Color.fromARGB(255, 217, 182, 250).withOpacity(.3),
      const Color.fromARGB(255, 200, 242, 156).withOpacity(.3),
      const Color.fromARGB(255, 255, 183, 212).withOpacity(.3),
    ];

    return SizedBox(
      height: size.height * 0.3,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getResponsiveColumnCount(size),
          crossAxisSpacing: size.width * 0.015,
          mainAxisSpacing: size.height * 0.015,
          childAspectRatio: _calculateChildAspectRatio(size),
        ),
        itemCount: statusCardData.length,
        itemBuilder: (context, index) {
          return CustomCard(
            title: statusCardData[index]["title"] ?? "",
            subtitle: statusCardData[index]["subtitle"] ?? "",
            icon: statusCardData[index]["icon"] ?? Icons.help_outline,
            fillColor: indicatorColors[index % indicatorColors.length],
          );
        },
      ),
    );
  }

  Widget _buildAttendanceChart(Size size) {
    return SizedBox(
      height: size.height * 0.26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _attendancePercentage),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, _) {
              return PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: size.width * 0.2,
                  sections: _buildPieChartSections(value, size),
                ),
              );
            },
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _attendancePercentage),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, _) {
              return CustomTitleText3(text: '${value.toInt()}%');
            },
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(double value, Size size) {
    return [
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
    ];
  }

  int _getResponsiveColumnCount(Size size) {
    if (size.width > 900) return 4;
    if (size.width > 600) return 3;
    return 2;
  }

  double _calculateChildAspectRatio(Size size) {
    return size.width / (size.height * 0.3);
  }
}
