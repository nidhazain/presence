
// //dashboard_integrated
// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:flutter/material.dart';
// // import 'package:presence/src/common_widget/custom_card.dart';
// // import 'package:presence/src/common_widget/submitbutton.dart';
// // import 'package:presence/src/common_widget/text_tile.dart';
// // import 'package:presence/src/constants/colors.dart';
// // import 'package:presence/src/features/api/employee/attendanceapi.dart';

// // class HomePage extends StatefulWidget {
// //   const HomePage({super.key});

// //   @override
// //   HomePageState createState() => HomePageState();
// // }

// // class HomePageState extends State<HomePage> {
// //   double attendancePercentage = 0;
// //   String checkInTime = "Not Available";
// //   String checkOutTime = "Not Available";
// //   String lateStatus = "No";
// //   String totalOvertime = "0 minutes";
// //   String shift = "Not Assigned";
// //   String date = "";
// //   // String title = 'Night shift';
// //   // String subtitle = 'Jan 20';
// //   // List<String> colleagues = [
// //   //   "John Doe",
// //   //   "Jane Smith",
// //   //   "Emily Johnson",
// //   //   "Michael Brown"
// //   // ];

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Future.delayed(const Duration(milliseconds: 500), () {
// //     //   setState(() {
// //     //     attendancePercentage = 70;
// //     //   });
// //     // });
// //     _loadDashboardData();
// //   }

// //   Future<void> _loadDashboardData() async {
// //     var data = await AttendanceService.fetchEmployeeDashboard();
// //     if (data != null) {
// //       setState(() {
// //         checkInTime = data["check_in"] ?? "Not Available";
// //         checkOutTime = data["check_out"] ?? "Not Available";
// //         lateStatus = data["late"] ? "Yes" : "No";
// //         totalOvertime = data["total_overtime"] ?? "0 minutes";
// //         attendancePercentage = data["attendance_percentage"]?.toDouble() ?? 0;
// //         shift = data["shift"] ?? "Not Assigned";
// //         date = data["date"] ?? "";
// //       });
// //     }
// //   }

// //   // void _showColleaguesPopup() {
// //   //   showDialog(
// //   //     context: context,
// //   //     builder: (context) {
// //   //       return AlertDialog(
// //   //         title: CustomTitleText3(text: title),
// //   //         content: SizedBox(
// //   //           width: MediaQuery.of(context).size.width * 0.8,
// //   //           child: ListView.builder(
// //   //             shrinkWrap: true,
// //   //             itemCount: colleagues.length,
// //   //             itemBuilder: (context, index) {
// //   //               return ListTile(
// //   //                 title: CustomTitleText9(text: colleagues[index]),
// //   //               );
// //   //             },
// //   //           ),
// //   //         ),
// //   //         actions: [
// //   //           CustomButton(
// //   //               text: 'close',
// //   //               onPressed: () {
// //   //                 Navigator.pop(context);
// //   //               })
// //   //         ],
// //   //       );
// //   //     },
// //   //   );
// //   // }

// //   @override
// //   Widget build(BuildContext context) {
// //     final size = MediaQuery.of(context).size;

// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Padding(
// //         padding: EdgeInsets.all(size.width * 0.03),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             children: [
// //               SizedBox(height: size.height * 0.01),
// //               SizedBox(
// //                 height: size.height * 0.3,
// //                 child: GridView.builder(
// //                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //             crossAxisCount: size.width > 600 ? 3 : 2, // Responsive columns
// //             crossAxisSpacing: size.width * 0.015,
// //             mainAxisSpacing: size.height * 0.015,
// //             childAspectRatio: size.width / (size.height * 0.3),
// //           ),
// //                   itemCount: 4,
// //                   itemBuilder: (context, index) {
// //                     return CustomCard(
// //                       title: [
// //                         "Check-in",
// //                         "Check-out",
// //                         "Late",
// //                         "Overtime"
// //                       ][index],
// //                       subtitle: [
// //                         "09:00 am",
// //                         "06:00 pm",
// //                         "8 min",
// //                         "2 hrs"
// //                       ][index],
// //                     );
// //                   },
// //                 ),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.all(10),
// //                 child: Align(
// //                     alignment: Alignment.centerLeft,
// //                     child: CustomTitleText8(text: 'Attendance Percentage')),
// //               ),
// //               SizedBox(height: size.height * 0.02),
// //               SizedBox(
// //                 height: size.height * 0.26,
// //                 child: Stack(
// //                   alignment: Alignment.center,
// //                   children: [
// //                     TweenAnimationBuilder<double>(
// //                       tween: Tween(begin: 0, end: attendancePercentage),
// //                       duration: const Duration(seconds: 2),
// //                       curve: Curves.easeInOut,
// //                       builder: (context, value, _) {
// //                         return PieChart(
// //                           PieChartData(
// //                             sectionsSpace: 0,
// //                             centerSpaceRadius: size.width * 0.2,
// //                             sections: [
// //                               PieChartSectionData(
// //                                 value: value,
// //                                 title: '',
// //                                 showTitle: false,
// //                                 radius: size.width * 0.05,
// //                                 color: purple,
// //                               ),
// //                               PieChartSectionData(
// //                                 value: 100 - value,
// //                                 title: '',
// //                                 showTitle: false,
// //                                 radius: size.width * 0.05,
// //                                 color: purple.withOpacity(0.3),
// //                               ),
// //                             ],
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                     TweenAnimationBuilder<double>(
// //                       tween: Tween(begin: 0, end: attendancePercentage),
// //                       duration: const Duration(seconds: 2),
// //                       curve: Curves.easeInOut,
// //                       builder: (context, value, _) {
// //                         return CustomTitleText3(text: '${value.toInt()}%');
// //                       },
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: size.height * 0.03),
// //               // GestureDetector(
// //               //   onTap: _showColleaguesPopup,
// //               //   child: CustomCard2(title: title, subtitle: subtitle),
// //               // ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// //leave_history
// // import 'package:flutter/material.dart';
// // import 'package:presence/src/common_widget/custom_card.dart';
// // import 'package:presence/src/common_widget/submitbutton.dart';
// // import 'package:presence/src/common_widget/text_tile.dart';
// // import 'package:presence/src/constants/colors.dart';

// // class Leave {
// //   final String type;
// //   final String startDate;
// //   final String? endDate;
// //   final String status;
// //   final String reason;

// //   Leave({
// //     required this.type,
// //     required this.startDate,
// //     this.endDate,
// //     required this.status,
// //     required this.reason,
// //   });
// // }

// // // Dummy Data (Replace with database fetch later)
// // final List<Leave> leaveList = [
// //   Leave(
// //       type: 'Sick Leave',
// //       startDate: '4-12-2024',
// //       status: 'pending',
// //       reason: 'Fever and cold'),
// //   Leave(
// //       type: 'Casual Leave',
// //       startDate: '11-12-2024',
// //       status: 'approved',
// //       reason: 'Family function'),
// //   Leave(
// //       type: 'Earned Leave',
// //       startDate: '20-12-2024',
// //       status: 'rejected',
// //       reason: 'Vacation trip'),
// //   Leave(
// //       type: 'Sick Leave',
// //       startDate: '4-12-2024',
// //       status: 'pending',
// //       reason: 'Migraine issue',
// //       endDate: '5-12-2024'),
// // ];

// // class LeaveHistory extends StatelessWidget {
// //   const LeaveHistory({super.key});

// //   // Function to get status color
// //   Color getStatusColor(String status) {
// //     switch (status.toLowerCase()) {
// //       case 'approved':
// //         return green;
// //       case 'rejected':
// //         return red;
// //       case 'pending':
// //       default:
// //         return orange;
// //     }
// //   }

// //   void showLeaveDetailsDialog(BuildContext context, Leave leave) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// //         title: Text(leave.type, style: TextStyle(fontWeight: FontWeight.bold)),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             CustomTitleText10(text: "Status: "),
// //             textfield(data: leave.status,),
// //             CustomTitleText10(text: "Date:"),
// //             textfield(data: leave.endDate != null
// //                     ? " ${leave.startDate} to ${leave.endDate}"
// //                     : leave.startDate,),
// //             CustomTitleText10(text: "Reason:"),
// //             textfield(data: leave.reason)
// //           ],
// //         ),
// //         actions: [CustomButton(text: 'Close', onPressed: () {
// //           Navigator.pop(context);
// //         })],
// //       ),
// //     );
// //   }

// //   void showCancelDialog(BuildContext context) {
// //     TextEditingController reasonController = TextEditingController();
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// //         title: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Text("Cancel Leave", style: TextStyle(fontWeight: FontWeight.bold)),
// //             IconButton(
// //               icon: Icon(Icons.close),
// //               onPressed: () => Navigator.pop(context),
// //             ),
// //           ],
// //         ),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             CustomTitleText10(text: "Reason for Cancellation:"),
// //             TextField(
// //                 controller: reasonController,
// //                 decoration: InputDecoration(hintText: "Enter reason")),
// //           ],
// //         ),
// //         actions: [
// //           CustomButton(
// //             text: 'Submit',
// //             onPressed: () {
// //               // Handle cancellation logic here
// //               Navigator.pop(context);
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenWidth = MediaQuery.of(context).size.width;
// //     final double screenHeight = MediaQuery.of(context).size.height;

// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
// //         child: ListView.separated(
// //           itemCount: leaveList.length,
// //           separatorBuilder: (context, index) =>
// //               SizedBox(height: screenHeight * 0.01),
// //           itemBuilder: (context, index) {
// //             final leave = leaveList[index];
// //             return GestureDetector(
// //               onTap: () => showLeaveDetailsDialog(context, leave),
// //               child: Container(
// //                 width: double.infinity,
// //                 padding: EdgeInsets.all(screenWidth * 0.03),
// //                 decoration: BoxDecoration(
// //                   color: primary.withOpacity(.1),
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         CustomTitleText10(text: leave.type),
// //                         SizedBox(height: screenHeight * 0.005),
// //                         CustomTitleText9(text: leave.startDate),
// //                       ],
// //                     ),
// //                     Row(
// //                       children: [
// //                         CircleAvatar(
// //                           backgroundColor: getStatusColor(leave.status),
// //                           radius: screenWidth * 0.015,
// //                         ),
// //                         SizedBox(width: screenWidth * 0.02),
// //                         CustomTitleText9(text: leave.status),
// //                         if (leave.status.toLowerCase() == 'approved')
// //                           SizedBox(width: screenWidth * 0.02),
// //                           if (leave.status.toLowerCase() == 'approved')
// //                           TextButton(
// //                             onPressed: () => showCancelDialog(context),
// //                             child: Text("Cancel", style: TextStyle(color: Colors.red)),
// //                           ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }


// //overtime_history
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:presence/src/common_widget/custom_card.dart';
// // import 'package:presence/src/common_widget/text_tile.dart';

// // class OvertimeHistoryPage extends StatelessWidget {
// //   const OvertimeHistoryPage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final screenHeight = MediaQuery.of(context).size.height;

// //     List<OvertimeEntry> overtimeEntries = [
// //       OvertimeEntry(date: DateTime(2025, 2, 15), hours: 4, status: OvertimeStatus.done),
// //       OvertimeEntry(date: DateTime(2025, 2, 18), hours: 2, status: OvertimeStatus.done),
// //       OvertimeEntry(date: DateTime(2025, 2, 22), hours: 3, status: OvertimeStatus.missed),
// //       OvertimeEntry(date: DateTime(2025, 2, 25), hours: 5, status: OvertimeStatus.upcoming),
// //       OvertimeEntry(date: DateTime(2025, 3, 1), hours: 2, status: OvertimeStatus.upcoming),
// //       OvertimeEntry(date: DateTime(2025, 5, 5), hours: 4, status: OvertimeStatus.done),
// //       OvertimeEntry(date: DateTime(2025, 3, 18), hours: 2, status: OvertimeStatus.done),
// //       OvertimeEntry(date: DateTime(2025, 9, 27), hours: 3, status: OvertimeStatus.missed),
// //       OvertimeEntry(date: DateTime(2025, 5, 2), hours: 5, status: OvertimeStatus.upcoming),
// //       OvertimeEntry(date: DateTime(2025, 7, 1), hours: 2, status: OvertimeStatus.upcoming),
// //     ];

// //     // Categorizing overtime entries
// //     List<OvertimeEntry> upcoming = overtimeEntries.where((e) => e.status == OvertimeStatus.upcoming).toList();
// //     List<OvertimeEntry> done = overtimeEntries.where((e) => e.status == OvertimeStatus.done).toList();
// //     List<OvertimeEntry> missed = overtimeEntries.where((e) => e.status == OvertimeStatus.missed).toList();

// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Padding(
// //         padding: EdgeInsets.all(screenWidth * 0.04),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildSection("Upcoming", upcoming, screenHeight),
// //               _buildSection("Done", done, screenHeight),
// //               _buildSection("Missed", missed, screenHeight),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   /// Builds a section with a title and list of overtime entries
// //   Widget _buildSection(String title, List<OvertimeEntry> entries, double screenHeight) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         CustomTitleText8(text: title),
// //         SizedBox(height: screenHeight * 0.015),
// //         entries.isEmpty
// //             ? const Text("No records available.", style: TextStyle(color: Colors.grey))
// //             : Column(
// //                 children: entries.map((e) => _buildOvertimeCard(e, screenHeight)).toList(),
// //               ),
// //         SizedBox(height: screenHeight * 0.03),
// //       ],
// //     );
// //   }

// //   /// Creates an individual overtime card with spacing
// //   Widget _buildOvertimeCard(OvertimeEntry entry, double screenHeight) {
// //     return Padding(
// //       padding: EdgeInsets.only(bottom: screenHeight * 0.01), // Adds space below each card
// //       child: CustomCard4(
// //         title: DateFormat("dd MMM").format(entry.date),
// //         subtitle: "${entry.hours} hours",
// //       ),
// //     );
// //   }
// // }

// // /// Enum to define overtime status
// // enum OvertimeStatus { upcoming, done, missed }

// // /// Model class for an overtime entry
// // class OvertimeEntry {
// //   final DateTime date;
// //   final int hours;
// //   final OvertimeStatus status;

// //   OvertimeEntry({required this.date, required this.hours, required this.status});
// // }




// // import 'package:flutter/material.dart';
// // import 'package:presence/src/common_pages/cancellation.dart';
// // import 'package:presence/src/common_pages/leave_history.dart';
// // import 'package:presence/src/common_pages/leaveform.dart';
// // import 'package:presence/src/common_widget/text_tile.dart';
// // import 'package:presence/src/constants/colors.dart';
// // import 'package:presence/src/features/api/api.dart';


// // class LeavePage extends StatefulWidget {
// //   const LeavePage({super.key});

// //   @override
// //   _LeavePageState createState() => _LeavePageState();
// // }

// // class _LeavePageState extends State<LeavePage> {
// //   int _selectedIndex = 0;
// //   final List<String> tabs = ["request", "history"];
// //   final List<Widget> content = [
// //     LeaveForm(),
// //     LeaveHistory(),
// //     CancelApprovedLeavePage(),
// //   ];

// //   int totalLeave = 0;
// //   int usedLeave = 0;
// //   int availableLeave = 0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchLeaveData();
// //   }

// //   Future<void> fetchLeaveData() async {
// //     try {
// //       final leaveData = await LeaveService.getLeaveBalance();
// //       setState(() {
// //         totalLeave = leaveData['total_leave'];
// //         usedLeave = leaveData['used_leave'];
// //         availableLeave = leaveData['available_leave'];
// //       });
// //     } catch (e) {
// //       print("Error fetching leave balance: $e");
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenWidth = MediaQuery.of(context).size.width;
// //     final double screenHeight = MediaQuery.of(context).size.height;
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Column(
// //         children: [
// //           const SizedBox(height: 20),
// //           Container(
// //               margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
// //               padding: EdgeInsets.all(screenWidth * 0.025),
// //               height: screenHeight * 0.11,
// //               width: double.infinity,
// //               decoration: BoxDecoration(
// //                   border: Border.symmetric(
// //                 vertical: BorderSide.none,
// //                 horizontal:
// //                     BorderSide(width: 2, color: primary.withOpacity(.3)),
// //               )),
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: Align(
// //                       alignment: Alignment.center,
// //                       child: Column(
// //                         children: [
// //                           CustomTitleText9(text: 'Balance leave'),
// //                           CustomTitleText5(text: '$availableLeave'),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                   Container(
// //                     margin: EdgeInsets.all(screenWidth * 0.025),
// //                     width: 2,
// //                     height: screenHeight * 0.05,
// //                     color: primary.withOpacity(0.3),
// //                   ),
// //                   Expanded(
// //                     child: Align(
// //                       alignment: Alignment.center,
// //                       child: Column(
// //                         children: [
// //                           CustomTitleText9(text: 'Used leave'),
// //                           CustomTitleText5(text: '$usedLeave'),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               )),
// //           const SizedBox(height: 20),
// //           Expanded(
// //             child: AnimatedSwitcher(
// //               duration: const Duration(milliseconds: 500),
// //               child: Container(
// //                 key: ValueKey<int>(_selectedIndex),
// //                 padding: EdgeInsets.all(screenWidth * 0.05),
// //                 child: content[_selectedIndex],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:fl_chart/fl_chart.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Attendance Chart',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //         fontFamily: 'Poppins',
// //         scaffoldBackgroundColor: Colors.white,
// //       ),
// //       home: const AttendanceChartScreen(),
// //       debugShowCheckedModeBanner: false,
// //     );
// //   }
// // }

// // class AttendanceChartScreen extends StatefulWidget {
// //   const AttendanceChartScreen({Key? key}) : super(key: key);

// //   @override
// //   State<AttendanceChartScreen> createState() => _AttendanceChartScreenState();
// // }

// // class _AttendanceChartScreenState extends State<AttendanceChartScreen> with SingleTickerProviderStateMixin {
// //   late AnimationController _animationController;
// //   late Animation<double> _animation;
// //   String _selectedPeriod = 'weekly';
// //   final List<String> _periods = ['daily', 'weekly', 'monthly', 'yearly'];

// //   // Sample data for the chart
// //   final List<AttendanceData> _weeklyData = [
// //     AttendanceData('M', 80, 40, 70), // present, late, absent
// //     AttendanceData('T', 85, 35, 70),
// //     AttendanceData('W', 110, 40, 60),
// //     AttendanceData('T', 70, 80, 60),
// //     AttendanceData('F', 125, 40, 30),
// //     AttendanceData('S', 150, 30, 20),
// //     AttendanceData('S', 0, 0, 0), // Sunday - no data
// //   ];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1500),
// //     );
    
// //     _animation = CurvedAnimation(
// //       parent: _animationController,
// //       curve: Curves.easeInOut,
// //     );
    
// //     _animationController.forward();
// //   }

// //   @override
// //   void dispose() {
// //     _animationController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text(
// //           'Attendance Overview',
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text(
// //               'Staff Attendance Summary',
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             Row(
// //               children: [
// //                 _buildLegendItem(Colors.black, 'present'),
// //                 const SizedBox(width: 16),
// //                 _buildLegendItem(Colors.purple.withOpacity(0.7), 'late'),
// //                 const SizedBox(width: 16),
// //                 _buildLegendItem(Colors.lightBlue.withOpacity(0.3), 'absent'),
// //                 const Spacer(),
// //                 _buildPeriodDropdown(),
// //               ],
// //             ),
// //             const SizedBox(height: 24),
// //             Expanded(
// //               child: AnimatedBuilder(
// //                 animation: _animation,
// //                 builder: (context, child) {
// //                   return BarChart(
// //                     BarChartData(
// //                       alignment: BarChartAlignment.spaceAround,
// //                       maxY: 200,
// //                       barTouchData: BarTouchData(
// //                         enabled: true,
// //                         touchTooltipData: BarTouchTooltipData(
// //                           tooltipBgColor: Colors.grey.shade800,
// //                           getTooltipItem: (group, groupIndex, rod, rodIndex) {
// //                             String label = '';
// //                             switch (rodIndex) {
// //                               case 0:
// //                                 label = 'Present: ${(rod.toY * _animation.value).toInt()}';
// //                                 break;
// //                               case 1:
// //                                 label = 'Late: ${(rod.toY * _animation.value).toInt()}';
// //                                 break;
// //                               case 2:
// //                                 label = 'Absent: ${(rod.toY * _animation.value).toInt()}';
// //                                 break;
// //                             }
// //                             return BarTooltipItem(
// //                               label,
// //                               const TextStyle(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             );
// //                           },
// //                         ),
// //                       ),
// //                       titlesData: FlTitlesData(
// //                         show: true,
// //                         bottomTitles: AxisTitles(
// //                           sideTitles: SideTitles(
// //                             showTitles: true,
// //                             getTitlesWidget: (value, meta) {
// //                               final index = value.toInt();
// //                               if (index >= 0 && index < _weeklyData.length) {
// //                                 return Padding(
// //                                   padding: const EdgeInsets.only(top: 8.0),
// //                                   child: Text(
// //                                     _weeklyData[index].day,
// //                                     style: const TextStyle(
// //                                       fontWeight: FontWeight.bold,
// //                                       fontSize: 14,
// //                                     ),
// //                                   ),
// //                                 );
// //                               }
// //                               return const SizedBox();
// //                             },
// //                           ),
// //                         ),
// //                         leftTitles: AxisTitles(
// //                           sideTitles: SideTitles(
// //                             showTitles: true,
// //                             reservedSize: 30,
// //                             getTitlesWidget: (value, meta) {
// //                               if (value % 50 == 0) {
// //                                 return Padding(
// //                                   padding: const EdgeInsets.only(right: 8.0),
// //                                   child: Text(
// //                                     value.toInt().toString(),
// //                                     style: const TextStyle(
// //                                       fontSize: 12,
// //                                       color: Colors.grey,
// //                                     ),
// //                                   ),
// //                                 );
// //                               }
// //                               return const SizedBox();
// //                             },
// //                           ),
// //                         ),
// //                         rightTitles: AxisTitles(
// //                           sideTitles: SideTitles(showTitles: false),
// //                         ),
// //                         topTitles: AxisTitles(
// //                           sideTitles: SideTitles(showTitles: false),
// //                         ),
// //                       ),
// //                       gridData: FlGridData(
// //                         show: true,
// //                         horizontalInterval: 50,
// //                         getDrawingHorizontalLine: (value) {
// //                           return FlLine(
// //                             color: Colors.grey.withOpacity(0.2),
// //                             strokeWidth: 1,
// //                           );
// //                         },
// //                         drawVerticalLine: false,
// //                       ),
// //                       borderData: FlBorderData(
// //                         show: false,
// //                       ),
// //                       barGroups: _getBarGroups(),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   List<BarChartGroupData> _getBarGroups() {
// //     return _weeklyData.asMap().entries.map((entry) {
// //       final int index = entry.key;
// //       final AttendanceData data = entry.value;
      
// //       // Skip Sunday (or any day with all zeros)
// //       if (data.present == 0 && data.late == 0 && data.absent == 0) {
// //         return BarChartGroupData(
// //           x: index,
// //           barRods: [],
// //         );
// //       }
      
// //       final double animValue = _animation.value;
      
// //       return BarChartGroupData(
// //         x: index,
// //         groupVertically: true,
// //         barRods: [
// //           BarChartRodData(
// //             toY: data.present * animValue,
// //             color: Colors.black,
// //             width: 32,
// //             borderRadius: BorderRadius.circular(0),
// //           ),
// //           BarChartRodData(
// //             toY: data.late * animValue,
// //             color: Colors.purple.withOpacity(0.7),
// //             width: 32,
// //             borderRadius: BorderRadius.circular(0),
// //           ),
// //           BarChartRodData(
// //             toY: data.absent * animValue,
// //             color: Colors.lightBlue.withOpacity(0.3),
// //             width: 32,
// //             borderRadius: BorderRadius.circular(0),
// //           ),
// //         ],
// //       );
// //     }).toList();
// //   }

// //   Widget _buildLegendItem(Color color, String label) {
// //     return Row(
// //       children: [
// //         Container(
// //           width: 16,
// //           height: 16,
// //           decoration: BoxDecoration(
// //             color: color,
// //             shape: BoxShape.circle,
// //           ),
// //         ),
// //         const SizedBox(width: 4),
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             fontSize: 14,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildPeriodDropdown() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: Colors.grey.shade200,
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: DropdownButtonHideUnderline(
// //         child: DropdownButton<String>(
// //           value: _selectedPeriod,
// //           isDense: true,
// //           icon: const Icon(Icons.keyboard_arrow_down, size: 18),
// //           items: _periods.map((String period) {
// //             return DropdownMenuItem<String>(
// //               value: period,
// //               child: Text(period),
// //             );
// //           }).toList(),
// //           onChanged: (String? newValue) {
// //             if (newValue != null) {
// //               setState(() {
// //                 _selectedPeriod = newValue;
// //                 // Here you would normally load new data based on the period
// //                 _animationController.reset();
// //                 _animationController.forward();
// //               });
// //             }
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class AttendanceData {
// //   final String day;
// //   final double present;
// //   final double late;
// //   final double absent;

// //   AttendanceData(this.day, this.present, this.late, this.absent);
// // }



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:presence/src/common_widget/submitbutton.dart';
// import 'package:presence/src/common_widget/text_tile.dart';
// import 'package:presence/src/constants/colors.dart';
// import 'package:presence/src/features/api/employee/leaveapi.dart';
// import 'package:presence/src/validations/validation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class LeaveForm extends StatefulWidget {
//   @override
//   State<LeaveForm> createState() => _LeaveFormState();
// }

// class _LeaveFormState extends State<LeaveForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _storage = FlutterSecureStorage();
//   final ImagePicker _picker = ImagePicker();
//   Map<String, dynamic>? _selectedLeaveType;
//   final TextEditingController _startDateController = TextEditingController();
//   final TextEditingController _endDateController = TextEditingController();
//   final TextEditingController _reasonController = TextEditingController();
//   bool _isSubmitting = false;
//   List<Map<String, dynamic>> _leaveTypes = []; // Store ID and name
//   bool _isLoading = true; // Loading state
//   File? _selectedImage; // Store the selected image

//   @override
//   void initState() {
//     super.initState();
//     //_fetchLeaveTypes();
//   }

//   Future<void> _fetchLeaveTypes() async {
//     try {
//       String? token = await _storage.read(key: 'access');
//       if (token == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Unauthorized: No token found')),
//         );
//         return;
//       }

//       List<Map<String, dynamic>> fetchedLeaveTypes =
//           await LeaveService.getLeaveTypes(token);

//       setState(() {
//         _leaveTypes = fetchedLeaveTypes;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching leave types')),
//       );
//     }
//   }

//   // Method to pick image from gallery or camera
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedImage = await _picker.pickImage(
//         source: source,
//         imageQuality: 80, // Reduce image quality to save bandwidth
//       );

//       if (pickedImage != null) {
//         setState(() {
//           _selectedImage = File(pickedImage.path);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking image: ${e.toString()}')),
//       );
//     }
//   }

//   // Show image source selection dialog
//   void _showImageSourceDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               CustomTitleText10(text: 'Select Image Source'),
//               CloseButton(
//                 // Close button at top right
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 GestureDetector(
//                   child: ListTile(
//                     leading: Icon(Icons.photo_library),
//                     title: Text('Gallery'),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImage(ImageSource.gallery);
//                   },
//                 ),
//                 GestureDetector(
//                   child: ListTile(
//                     leading: Icon(Icons.photo_camera),
//                     title: Text('Camera'),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImage(ImageSource.camera);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Image preview widget
//   Widget _buildImagePreview() {
//     return Container(
//       height: 150,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: primary.withOpacity(.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: _selectedImage == null
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.image, size: 50, color: Colors.grey),
//                   SizedBox(height: 8),
//                   Text('No image selected',
//                       style: TextStyle(color: Colors.grey)),
//                 ],
//               ),
//             )
//           : ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Stack(
//                 children: [
//                   // Image preview
//                   Image.file(
//                     _selectedImage!,
//                     width: double.infinity,
//                     height: 150,
//                     fit: BoxFit.cover,
//                   ),
//                   // Remove button
//                   Positioned(
//                     top: 5,
//                     right: 5,
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _selectedImage = null;
//                         });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.all(5),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.7),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(Icons.close, size: 20, color: Colors.red),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildDropdown() {
//     if (_isLoading) {
//       return Center(child: CircularProgressIndicator());
//     }

//     return DropdownButtonFormField<Map<String, dynamic>>(
//       value: _selectedLeaveType,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: primary.withOpacity(.1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: BorderSide.none,
//         ),
//       ),
//       icon: Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
//       hint: Text("Select type"),
//       items: _leaveTypes.map((type) {
//         return DropdownMenuItem<Map<String, dynamic>>(
//           value: type,
//           child: Text(type["name"]), // Show name
//         );
//       }).toList(),
//       validator: (value) => value == null ? "Please select a leave type" : null,
//       onChanged: (Map<String, dynamic>? newValue) {
//         setState(() {
//           _selectedLeaveType = newValue;
//         });
//       },
//     );
//   }

//   void _clearForm() {
//     setState(() {
//       _selectedLeaveType = null;
//       _startDateController.clear();
//       _endDateController.clear();
//       _reasonController.clear();
//       _selectedImage = null;
//     });
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isSubmitting = true);

//       String? token = await _storage.read(key: 'access');
//       if (token == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Unauthorized: No token found')),
//         );
//         setState(() => _isSubmitting = false);
//         return;
//       }

//       // Handle image upload logic here
//       // You'd typically convert image to base64 or multipart form data
//       // and include it in your API request

//       final response = await LeaveService.submitLeaveRequest(
//         token: token,
//         startDate: _startDateController.text,
//         endDate: _endDateController.text,
//         leaveType: _selectedLeaveType != null
//             ? _selectedLeaveType!["id"].toString()
//             : "", // Convert to String
//         reason: _reasonController.text,
//         // Add image parameter here for your API
//         // image: _selectedImage,
//       );

//       setState(() => _isSubmitting = false);

//       if (response.containsKey('error')) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(response['error'])),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Leave request submitted successfully')),
//         );
//         _clearForm();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CustomTitleText9(text: 'Start Date'),
//                 _buildDateField(_startDateController, 'Select Start Date'),
//                 SizedBox(height: 16),

//                 CustomTitleText9(text: 'End Date'),
//                 _buildDateField(_endDateController, 'Select End Date'),
//                 SizedBox(height: 16),

//                 CustomTitleText9(text: 'Leave Type'),
//                 //_buildDropdown(),
//                 SizedBox(height: 16),

//                 CustomTitleText9(text: 'Reason'),
//                 _buildReasonField(),
//                 SizedBox(height: 16),

//                 // New image field
//                 CustomTitleText9(text: 'Supporting Document'),
//                 SizedBox(height: 8),
//                 _buildImagePreview(),
//                 SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   onPressed: _showImageSourceDialog,
//                   icon: Icon(Icons.add_a_photo),
//                   label: Text(
//                       _selectedImage == null ? 'Add Image' : 'Change Image'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primary,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 24),

//                 _buildButtons()
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDateField(TextEditingController controller, String hintText) {
//     return TextFormField(
//       controller: controller,
//       readOnly: true,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: primary.withOpacity(.1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: BorderSide.none,
//         ),
//         suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
//         hintText: hintText,
//       ),
//       validator: ValidationHelper.validateField,
//       onTap: () async {
//         DateTime? pickedDate = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime.now(),
//           lastDate: DateTime(2100),
//         );

//         if (pickedDate != null) {
//           setState(() {
//             controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//           });
//         }
//       },
//     );
//   }

//   Widget _buildReasonField() {
//     return TextFormField(
//       controller: _reasonController,
//       minLines: 3,
//       maxLines: 5,
//       keyboardType: TextInputType.multiline,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: primary.withOpacity(.1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: BorderSide.none,
//         ),
//         hintText: "Enter your reason",
//       ),
//       validator: ValidationHelper.validateField,
//     );
//   }

//   Widget _buildButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         Expanded(
//           child: CustomButton(
//             text: 'Clear',
//             onPressed: _clearForm,
//           ),
//         ),
//         SizedBox(width: 16),
//         Expanded(
//           child: CustomButton(
//             text: _isSubmitting ? 'Submitting...' : 'Submit',
//             onPressed: _isSubmitting ? () {} : _submitForm,
//           ),
//         ),
//       ],
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:presence/src/common_widget/custom_card.dart';
// import 'package:presence/src/common_widget/text_tile.dart';
// import 'package:presence/src/constants/colors.dart';

// class OvertimestatsPage extends StatefulWidget {
//   const OvertimestatsPage({super.key});

//   @override
//   State<OvertimestatsPage> createState() => _OvertimestatsPageState();
// }

// class _OvertimestatsPageState extends State<OvertimestatsPage> {
//   List<double> overtimeHours = [5, 7, 3, 8, 2, 6, 0, 8, 1, 4, 0, 9];
//   List<double> animatedValues = List.filled(12, 0);
//   int? selectedMonth; // Stores the selected month index
//   double? selectedHours; // Stores the selected hours

//   @override
//   void initState() {
//     super.initState();
//     _startAnimation();
//   }

//   void _startAnimation() {
//     Future.delayed(const Duration(milliseconds: 300), () {
//       setState(() {
//         animatedValues = List.from(overtimeHours);
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     const months = [
//       "Jan", "Feb", "Mar", "Apr", "May", "Jun",
//       "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
//     ];

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CustomTitleText8(text: 'Monthly Overtime Stats'),
//               SizedBox(height: screenHeight * 0.03),
//               SizedBox(
//                 height: screenHeight * 0.4,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: SizedBox(
//                     width: screenWidth * 1.5,
//                     child: Padding(
//                       padding: EdgeInsets.only(top: screenHeight * 0.05),
//                       child: BarChart(
//                         BarChartData(
//                           borderData: FlBorderData(show: false),
//                           gridData: FlGridData(show: true, drawVerticalLine: false),
//                           titlesData: FlTitlesData(
//                             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                             leftTitles: AxisTitles(
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 reservedSize: screenWidth * 0.15,
//                                 getTitlesWidget: (value, meta) {
//                                   return CustomTitleText10(text: "${value.toInt()} hrs");
//                                 },
//                               ),
//                             ),
//                             bottomTitles: AxisTitles(
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 reservedSize: screenHeight * 0.05,
//                                 getTitlesWidget: (value, meta) {
//                                   return Padding(
//                                     padding: EdgeInsets.only(top: screenHeight * 0.01),
//                                     child: CustomTitleText10(text: months[value.toInt()]),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           barTouchData: BarTouchData(
//                             touchTooltipData: BarTouchTooltipData(
//                               tooltipBgColor: blue.withOpacity(0.7),
//                             ),
//                             touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
//                               if (response != null &&
//                                   response.spot != null &&
//                                   event is FlTapUpEvent) {
//                                 setState(() {
//                                   selectedMonth = response.spot!.touchedBarGroupIndex;
//                                   selectedHours = overtimeHours[selectedMonth!];
//                                 });
//                               }
//                             },
//                           ),
//                           alignment: BarChartAlignment.spaceBetween,
//                           maxY: 10,
//                           minY: 0,
//                           barGroups: _getAnimatedOvertimeData(),
//                         ),
//                         swapAnimationDuration: const Duration(milliseconds: 800),
//                         swapAnimationCurve: Curves.easeInOut,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.03),

//               // Show the selected month card when a bar is tapped
//               if (selectedMonth != null)
//                 CustomCard5(
//                   title: months[selectedMonth!],
//                   subtitle: '${selectedHours!.toInt()} hrs',
//                   icons: Icon(Icons.bar_chart, size: 50),
//                 ),

//               SizedBox(height: screenHeight * 0.01),
//               CustomCard5(
//                 title: 'Total Hours',
//                 subtitle: '${overtimeHours.reduce((a, b) => a + b).toInt()} hrs',
//                 icons: Icon(Icons.hourglass_bottom, size: 50),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<BarChartGroupData> _getAnimatedOvertimeData() {
//     return List.generate(12, (index) {
//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: animatedValues[index],
//             color: blue,
//             width: 24,
//             borderRadius: BorderRadius.circular(4),
//             backDrawRodData: BackgroundBarChartRodData(
//               show: true,
//               toY: 12,
//               color: blue.withOpacity(0.1),
//             ),
//           ),
//         ],
//       );
//     });
//   }
// }


//profile page
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:presence/src/common_pages/changepassword.dart';
// import 'package:presence/src/common_widget/text_tile.dart';
// import 'package:presence/src/constants/colors.dart';
// import 'package:presence/src/features/api/employee/profileapi.dart';

// class ProfilePage extends StatefulWidget {
//   ProfilePage({super.key});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   File? _image;
//   final ImagePicker _picker = ImagePicker();

//   final TextEditingController fullNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController positionController = TextEditingController();
//   final TextEditingController departmentController = TextEditingController();
//   final TextEditingController communityController = TextEditingController();
//   final TextEditingController employeeIdController = TextEditingController();
//   final TextEditingController hiringDateController = TextEditingController();

//   String profileImageUrl = "";

//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//   }

//   Future<void> fetchUserData() async {
//     var profileData = await ProfileService.fetchProfileData();
//     if (profileData.isNotEmpty) {
//       setState(() {
//         fullNameController.text = profileData['name'] ?? "";
//         emailController.text = profileData['email'] ?? "";
//         positionController.text = profileData['position'] ?? "";
//         departmentController.text = profileData['department'] ?? "";
//         communityController.text = profileData['community_name'] ?? "";
//         employeeIdController.text = profileData['employee_id'] ?? "";
//         hiringDateController.text = profileData['hire_date'] ?? "";
//         profileImageUrl = profileData['image'] ?? "";
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => _image = File(pickedFile.path));
//       await ProfileService.updateProfileData(imagePath: _image?.path ?? "");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   GestureDetector(
//                     onTap: _pickImage,
//                     child: Stack(
//                       alignment: Alignment.bottomRight,
//                       children: [
//                         CircleAvatar(
//                           radius: 70,
//                           backgroundImage: _image != null
//                               ? FileImage(_image!)
//                               : (profileImageUrl.isNotEmpty
//                                   ? NetworkImage(profileImageUrl)
//                                       as ImageProvider
//                                   : const AssetImage('images/pro.jpg')
//                                       as ImageProvider),
//                         ),
//                         GestureDetector(
//                           onTap: _pickImage,
//                           child: const CircleAvatar(
//                             radius: 20,
//                             backgroundColor: Colors.white,
//                             child: Icon(Icons.camera_alt,
//                                 color: primary, size: 20),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 50),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               buildProfileField('Employee ID', employeeIdController),
//               buildProfileField('Full Name', fullNameController),
//               buildProfileField('Email', emailController),
//               buildProfileField('Position', positionController),
//               buildProfileField('Department', departmentController),
//               buildProfileField('Hiring Date', hiringDateController),
//               buildProfileField('Community', communityController),
//               const SizedBox(height: 10),
//               InkWell(
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ChangePasswordPage()),
//                 ),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: primary.withOpacity(.1),
//                   ),
//                   child: ListTile(
//                     title: CustomTitleText7(text: 'Change Password'),
//                     trailing:
//                         Icon(Icons.arrow_forward_ios, color: primary, size: 20),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildProfileField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CustomTitleText7(text: label),
//           const SizedBox(height: 4),
//           TextFormField(
//             controller: controller,
//             readOnly: true,
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: primary.withOpacity(0.1),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//shiftcalender
// import 'package:flutter/material.dart';
// import 'package:presence/src/common_widget/submitbutton.dart';
// import 'package:presence/src/common_widget/text_tile.dart';
// import 'package:presence/src/constants/colors.dart';
// import 'package:table_calendar/table_calendar.dart';

// class ShiftCalendarScreen extends StatefulWidget {
//   @override
//   _ShiftCalendarScreenState createState() => _ShiftCalendarScreenState();
// }

// class _ShiftCalendarScreenState extends State<ShiftCalendarScreen> {
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//     @override
//   void initState() {
//     super.initState();
//     _selectedDay = DateTime.now(); // Ensure today's card is visible initially
//   }

//   Map<DateTime, Map<String, String>> shiftRoster = {
//     DateTime(2025, 3, 3): {
//       "Alice": "Morning",
//       "John": "Morning",
//       "Bob": "Night",
//       "Charlie": "Intermediate"
//     },
//     DateTime(2025, 3, 4): {
//       "David": "Morning",
//       "Eve": "Intermediate",
//       "Frank": "Night"
//     },
//     DateTime(2025, 3, 5): {
//       "Alice": "Night",
//       "Bob": "Morning",
//       "Charlie": "Intermediate"
//     },
//     DateTime(2025, 3, 6): {
//       "George": "Intermediate",
//       "Helen": "Morning",
//       "Ian": "Night"
//     },
//     DateTime(2025, 3, 7): {
//       "Jack": "Morning",
//       "Karen": "Night",
//       "Leo": "Intermediate"
//     },
//     DateTime(2025, 3, 8): {
//       "Mike": "Morning",
//       "Nina": "Intermediate",
//       "Olivia": "Night"
//     },
//     DateTime(2025, 3, 10): {
//       "Steve": "Morning",
//       "Tina": "Intermediate",
//       "Uma": "Night"
//     },
//         DateTime(2025, 3, 31): {
//       "Steve": "Morning",
//       "Tina": "Intermediate",
//       "Uma": "Night"
//     },
//   };

//   Map<DateTime, List<String>> holidays = {
//     DateTime(2025, 1, 26): ['Republic Day'],
//     DateTime(2025, 8, 15): ['Independence Day'],
//     DateTime(2025, 3, 31): ['Eid'],
//     DateTime(2025, 4, 14): ['Tamil New Year'],
//     DateTime(2025, 12, 25): ['Christmas'],
//   };

//   DateTime _normalizeDate(DateTime date) {
//     return DateTime(date.year, date.month, date.day);
//   }

//   Color _getShiftColor(String? shift) {
//     switch (shift) {
//       case 'Morning':
//         return blue;
//       case 'Night':
//         return purple;
//       case 'Intermediate':
//         return Colors.green;
//       default:
//         return primary;
//     }
//   }

//   String? _getShiftForDay(DateTime day) {
//     var normalizedDate = _normalizeDate(day);
//     if (shiftRoster.containsKey(normalizedDate)) {
//       return shiftRoster[normalizedDate]?.values.first;
//     }
//     return null;
//   }

//   List<String> _getColleaguesForShift(DateTime day) {
//     var normalizedDate = _normalizeDate(day);
//     String? userShift = _getShiftForDay(day);
//     if (userShift == null) return [];

//     return shiftRoster[normalizedDate]
//             ?.entries
//             .where((entry) => entry.value == userShift)
//             .map((entry) => entry.key)
//             .toList() ??
//         [];
//   }

//   bool _isHoliday(DateTime day) {
//     return holidays.containsKey(_normalizeDate(day));
//   }

//   @override
//   Widget build(BuildContext context) {
//     //final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: screenHeight * 0.02),
//             TableCalendar(
//               focusedDay: _focusedDay,
//               firstDay: DateTime(2024, 1, 1),
//               lastDay: DateTime(2025, 12, 31),
//               calendarFormat: _calendarFormat,
//               onFormatChanged: (format) {
//                 setState(() {
//                   _calendarFormat = format;
//                 });
//               },
//               selectedDayPredicate: (day) {
//                 return isSameDay(_selectedDay, day);
//               },
//               onDaySelected: (selectedDay, focusedDay) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   setState(() {
//                     _selectedDay = selectedDay;
//                     _focusedDay = focusedDay;
//                   });
//                 });
//               },
//               calendarStyle: CalendarStyle(
//                 todayDecoration: BoxDecoration(
//                   color: primary,
//                   shape: BoxShape.circle,
//                 ),
//                 selectedDecoration: BoxDecoration(
//                   color: Colors.blueAccent,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               calendarBuilders: CalendarBuilders(
//                 defaultBuilder: (context, date, _) {
//                   bool isSunday = date.weekday == DateTime.sunday;
//                   bool isHoliday = _isHoliday(date);
//                   String? shift = _getShiftForDay(date);

//                   return Center(
//                     child: Text(
//                       '${date.day}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: (isSunday || isHoliday)
//                             ? Colors.red
//                             : _getShiftColor(shift),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             if (_selectedDay != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Card.outlined(
//                   shape: RoundedRectangleBorder(
//                     side: BorderSide(color: Colors.blue,width: 1.5),
//                     borderRadius: BorderRadius.circular(10)
//                   ),
//                   color: blue.withOpacity(.1),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ListTile(
//                           title: Text(
//                             _selectedDay == DateTime.now()
//                                 ? "Today's Shift: ${_getShiftForDay(_selectedDay!) ?? 'No Shift'}"
//                                 : "${_getShiftForDay(_selectedDay!) ?? 'No'} shift",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Text(
//                             _selectedDay == DateTime.now()
//                                 ? "Today"
//                                 : _selectedDay!
//                                     .toLocal()
//                                     .toString()
//                                     .split(' ')[0],
//                           ),
//                         ),
//                         if (_isHoliday(_selectedDay!))
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               "Holiday: ${holidays[_normalizeDate(_selectedDay!)]?.join(', ')}",
//                               style: TextStyle(
//                                   color: red,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         if (_getShiftForDay(_selectedDay!) != null)
//                           OutlinedButton(
//                             onPressed: () {
//                               List<String> colleagues =
//                                   _getColleaguesForShift(_selectedDay!);
//                               showDialog(
//                                 context: context,
//                                 builder: (context) {
//                                   return AlertDialog(
//                                     title: CustomTitleText8(
//                                         text: "Colleagues in this shift"),
//                                     content: colleagues.isNotEmpty
//                                         ? CustomTitleText9(
//                                             text: colleagues.join(", "))
//                                         : CustomTitleText9(
//                                             text:
//                                                 "No colleagues assigned to this shift."),
//                                     actions: [
//                                       CustomButton(
//                                           text: 'Close',
//                                           onPressed: () {
//                                             Navigator.pop(context);
//                                           })
//                                     ],
//                                   );
//                                 },
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               foregroundColor: primary
//                             ),
//                             child: Text('View Colleagues'),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:presence/src/common_widget/submitbutton.dart';
// import 'package:presence/src/common_widget/text_tile.dart';
// import 'package:presence/src/constants/colors.dart';
// import 'package:table_calendar/table_calendar.dart';

// class ShiftCalendarScreen extends StatefulWidget {
//   const ShiftCalendarScreen({super.key});

//   @override
//   _ShiftCalendarScreenState createState() => _ShiftCalendarScreenState();
// }

// class _ShiftCalendarScreenState extends State<ShiftCalendarScreen> {
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDay = DateTime.now(); // Ensure today's card is visible initially
//   }

//   // Shift roster data - would typically come from an API or database service
//   final Map<DateTime, Map<String, String>> shiftRoster = {
//     DateTime(2025, 3, 3): {
//       "Alice": "Morning",
//       "John": "Morning",
//       "Bob": "Night",
//       "Charlie": "Intermediate"
//     },
//     DateTime(2025, 3, 4): {
//       "David": "Morning",
//       "Eve": "Intermediate",
//       "Frank": "Night"
//     },
//     DateTime(2025, 3, 5): {
//       "Alice": "Night",
//       "Bob": "Morning",
//       "Charlie": "Intermediate"
//     },
//     DateTime(2025, 3, 6): {
//       "George": "Intermediate",
//       "Helen": "Morning",
//       "Ian": "Night"
//     },
//     DateTime(2025, 3, 7): {
//       "Jack": "Morning",
//       "Karen": "Night",
//       "Leo": "Intermediate"
//     },
//     DateTime(2025, 3, 8): {
//       "Mike": "Morning",
//       "Nina": "Intermediate",
//       "Olivia": "Night"
//     },
//     DateTime(2025, 3, 10): {
//       "Steve": "Morning",
//       "Tina": "Intermediate",
//       "Uma": "Night"
//     },
//     DateTime(2025, 3, 31): {
//       "Steve": "Morning",
//       "Tina": "Intermediate",
//       "Uma": "Night"
//     },
//   };

//   // Public holidays data - would typically come from an API or database service
//   final Map<DateTime, List<String>> holidays = {
//     DateTime(2025, 1, 26): ['Republic Day'],
//     DateTime(2025, 8, 15): ['Independence Day'],
//     DateTime(2025, 3, 31): ['Eid'],
//     DateTime(2025, 4, 14): ['Tamil New Year'],
//     DateTime(2025, 12, 25): ['Christmas'],
//   };

//   /// Normalizes date by removing time portion for comparison
//   DateTime _normalizeDate(DateTime date) {
//     return DateTime(date.year, date.month, date.day);
//   }

//   /// Returns color based on shift type
//   Color _getShiftColor(String? shift) {
//     switch (shift) {
//       case 'Morning':
//         return const Color.fromARGB(255, 54, 144, 240);
//       case 'Night':
//         return const Color.fromARGB(255, 167, 69, 243);
//       case 'Intermediate':
//         return const Color.fromARGB(255, 55, 169, 59);
//       default:
//         return primary;
//     }
//   }

//   /// Gets a user's shift for a specific day
//   String? _getShiftForDay(DateTime day) {
//     var normalizedDate = _normalizeDate(day);
//     if (shiftRoster.containsKey(normalizedDate)) {
//       return shiftRoster[normalizedDate]?.values.first;
//     }
//     return null;
//   }

//   /// Gets list of colleagues working same shift on a specific day
//   List<String> _getColleaguesForShift(DateTime day) {
//     var normalizedDate = _normalizeDate(day);
//     String? userShift = _getShiftForDay(day);
//     if (userShift == null) return [];

//     return shiftRoster[normalizedDate]
//             ?.entries
//             .where((entry) => entry.value == userShift)
//             .map((entry) => entry.key)
//             .toList() ??
//         [];
//   }

//   /// Checks if a day is a holiday
//   bool _isHoliday(DateTime day) {
//     return holidays.containsKey(_normalizeDate(day));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: screenHeight * 0.02),
//             _buildCalendar(),
//             SizedBox(height: screenHeight * 0.02),
//             if (_selectedDay != null) _buildSelectedDayCard(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCalendar() {
//     return TableCalendar(
//       focusedDay: _focusedDay,
//       firstDay: DateTime(2024, 1, 1),
//       lastDay: DateTime(2025, 12, 31),
//       calendarFormat: _calendarFormat,
//       onFormatChanged: (format) {
//         setState(() {
//           _calendarFormat = format;
//         });
//       },
//       selectedDayPredicate: (day) {
//         return isSameDay(_selectedDay, day);
//       },
//       onDaySelected: (selectedDay, focusedDay) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           setState(() {
//             _selectedDay = selectedDay;
//             _focusedDay = focusedDay;
//           });
//         });
//       },
//       calendarStyle: CalendarStyle(
//         todayDecoration: BoxDecoration(
//           color: primary,
//           shape: BoxShape.circle,
//         ),
//         selectedDecoration: BoxDecoration(
//           color: Colors.blueAccent,
//           shape: BoxShape.circle,
//         ),
//         // Mark holidays in red
//         holidayTextStyle: const TextStyle(color: Colors.red),
//         markerDecoration: BoxDecoration(
//           color: primary,
//           shape: BoxShape.circle,
//         ),
//       ),
//       calendarBuilders: CalendarBuilders(
//         // Custom day cell builder
//         defaultBuilder: (context, date, _) {
//           bool isHoliday = _isHoliday(date);
//           String? shift = _getShiftForDay(date);
          
//           // Custom styling based on day type
//           return Container(
//             margin: const EdgeInsets.all(4.0),
//             alignment: Alignment.center,
            
//             child: Text(
//               '${date.day}',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: (isHoliday)
//                     ? Colors.red
//                     : _getShiftColor(shift),
//               ),
//             ),
//           );
//         },
//         // Additional customization for holidays
//         holidayBuilder: (context, date, _) {
//           return Container(
//             margin: const EdgeInsets.all(4.0),
//             alignment: Alignment.center,
//             child: Text(
//               '${date.day}',
//               style: const TextStyle(
//                 color: Colors.red,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           );
//         },
//         // Highlight today's date
//         todayBuilder: (context, date, _) {
//           bool isHoliday = _isHoliday(date);
          
//           return Container(
//             margin: const EdgeInsets.all(4.0),
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isHoliday ? Colors.red.withOpacity(0.2) : primary.withOpacity(0.7),
//               border: Border.all(
//                 color: isHoliday ? Colors.red : primary,
//                 width: 1.5,
//               ),
//             ),
//             child: Text(
//               '${date.day}',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           );
//         },
//         // Selected day builder
//         selectedBuilder: (context, date, _) {
//           bool isHoliday = _isHoliday(date);
          
//           return Container(
//             margin: const EdgeInsets.all(4.0),
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isHoliday ? Colors.red.withOpacity(0.7) : Colors.blueAccent,
//             ),
//             child: Text(
//               '${date.day}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           );
//         },
//       ),
//       // Mark holidays in the calendar
//       holidayPredicate: (day) {
//         return _isHoliday(day);
//       },
//     );
//   }

//   Widget _buildSelectedDayCard() {
//     final String? currentShift = _getShiftForDay(_selectedDay!);
//     final bool isHoliday = _isHoliday(_selectedDay!);
//     final bool isToday = isSameDay(_selectedDay!, DateTime.now());
    
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Card.outlined(
//         shape: RoundedRectangleBorder(
//           side: BorderSide(
//             color: isHoliday 
//                 ? Colors.red 
//                 : (currentShift != null 
//                     ? _getShiftColor(currentShift) 
//                     : Colors.blue),
//             width: 1.5
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         color: (isHoliday 
//             ? Colors.red 
//             : (currentShift != null 
//                 ? _getShiftColor(currentShift) 
//                 : blue)
//         ).withOpacity(.1),
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ListTile(
//                 title: Text(
//                   isToday
//                       ? "Today's Shift: ${currentShift ?? 'No Shift'}"
//                       : "${currentShift ?? 'No'} shift",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 subtitle: Text(
//                   isToday
//                       ? "Today"
//                       : _selectedDay!.toLocal().toString().split(' ')[0],
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ),
//               if (isHoliday)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(8.0),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.red),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.celebration, color: Colors.red),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             "Holiday: ${holidays[_normalizeDate(_selectedDay!)]?.join(', ')}",
//                             style: const TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               if (currentShift != null)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   child: OutlinedButton.icon(
//                     //icon: const Icon(Icons.people),
//                     onPressed: _showColleaguesDialog,
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: primary,
//                       side: BorderSide(color: _getShiftColor(currentShift)),
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     ),
//                     label: const Text('View Colleagues'),
//                   ),
//                 ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Shows a dialog with colleagues working on the same shift
//   void _showColleaguesDialog() {
//     List<String> colleagues = _getColleaguesForShift(_selectedDay!);
//     final String? currentShift = _getShiftForDay(_selectedDay!);
    
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: CustomTitleText8(text: "Colleagues in $currentShift shift"),
//           content: colleagues.isNotEmpty
//               ? Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ...colleagues.map((colleague) => ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: _getShiftColor(currentShift).withOpacity(0.2),
//                         child: Text(
//                           colleague[0],
//                           style: TextStyle(
//                             color: _getShiftColor(currentShift),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       title: Text(colleague),
//                     )),
//                   ],
//                 )
//               : CustomTitleText9(text: "No colleagues assigned to this shift."),
//           actions: [
//             CustomButton(
//               text: 'Close',
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             )
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class LeaveRequestPage extends StatefulWidget {
  @override
  _LeaveRequestPageState createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  List<Map<String, dynamic>> leaveRequests = [
    {
      'type': 'Casual Leave',
      'startDate': '2025-03-12',
      'endDate': '2025-03-12',
      'reason': 'Family Function',
      'status': 'pending',
      'rejectReason': ''
    },
    {
      'type': 'Earned Leave',
      'startDate': '2025-03-15',
      'endDate': '2025-03-16',
      'reason': 'Medical Checkup',
      'status': 'accepted',
      'rejectReason': ''
    },
    {
      'type': 'Restricted Leave',
      'startDate': '2025-03-20',
      'endDate': '2025-03-20',
      'reason': 'Religious Festival',
      'status': 'rejected',
      'rejectReason': 'Not eligible for this leave type'
    },
    {
      'type': 'Casual Leave',
      'startDate': '2025-03-25',
      'endDate': '2025-03-26',
      'reason': 'Personal Work',
      'status': 'pending',
      'rejectReason': ''
    },
  ];

  final TextEditingController _rejectReasonController = TextEditingController();

  // Format date from yyyy-MM-dd to dd MMM yyyy
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  Color getStatusColor(String status) {
    if (status == 'accepted') return dgreen;
    if (status == 'rejected') return red;
    return Colors.orange;
  }

  void updateStatus(int index, String status, {String rejectReason = ''}) {
    setState(() {
      leaveRequests[index]['status'] = status;
      if (status == 'rejected') {
        leaveRequests[index]['rejectReason'] = rejectReason;
      }
      sortRequests();
    });
  }

  void sortRequests() {
    leaveRequests.sort((a, b) {
      if (a['status'] == 'pending' && b['status'] != 'pending') {
        return -1;
      } else if (a['status'] != 'pending' && b['status'] == 'pending') {
        return 1;
      }
      return 0;
    });
  }

  void showRejectConfirmation(int index) {
    _rejectReasonController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: CustomTitleText8(text: 'Confirm Rejection')),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to reject this leave request?"),
              SizedBox(height: 16),
              TextField(
                controller: _rejectReasonController,
                decoration: InputDecoration(
                  labelText: "Reason for rejection",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            CustomButton(
              text: 'confirm',
              onPressed: () {
                updateStatus(index, 'rejected',
                    rejectReason: _rejectReasonController.text);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _showFullSizeImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  void showLeaveDetailsDialog(
      BuildContext context, Map<String, dynamic> leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTitleText8(text: 'Leave Details'),
            CloseButton(onPressed: () => Navigator.pop(context)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTitleText10(text: "Leave Type:"),
                textfield(data: leave['type']),
                CustomTitleText10(text: "Period:"),
                textfield(
                    data:
                        "${formatDate(leave['startDate'])} - ${formatDate(leave['endDate'])}"),
                CustomTitleText10(text: "Reason:"),
                textfield(data: leave['reason']),
                if (leave['status'] != 'pending') ...[
                  CustomTitleText10(text: "Status:"),
                  textfield(
                    data: leave['status'].toUpperCase(),
                  ),
                ],
                if (leave['status'] == 'rejected' &&
                    leave['rejectReason'] != null &&
                    leave['rejectReason'].isNotEmpty) ...[
                  CustomTitleText10(text: "Rejection Reason:"),
                  textfield(data: leave['rejectReason']),
                ],
                if (leave['attachmentUrl'] != null &&
                    leave['attachmentUrl'].isNotEmpty) ...[
                  CustomTitleText10(text: "Attachment:"),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () =>
                        _showFullSizeImage(context, leave['attachmentUrl']),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          leave['attachmentUrl'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Text('Failed to load image'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    sortRequests();
    return Scaffold(
      backgroundColor: Colors.white,
     appBar:
          AppBar(title: CustomTitleText8(text: 'Leave Requests'), backgroundColor: Colors.white),
      body: ListView.separated(
        itemCount: leaveRequests.length,
        separatorBuilder: (context, index) => Divider(
            color: primary.withOpacity(.3),
            height: 1),
        itemBuilder: (context, index) {
          var leave = leaveRequests[index];
          return GestureDetector(
            onTap: () => showLeaveDetailsDialog(context, leave),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTitleText10(text: leave['type']),
                      SizedBox(height: 5),
                      CustomTitleText20(
                          text:
                              "${formatDate(leave['startDate'])} - ${formatDate(leave['endDate'])}")
                    ],
                  ),
                  leave['status'] == 'pending'
                      ? Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: dgreen),
                              onPressed: () => updateStatus(index, 'accepted'),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: red),
                              onPressed: () => showRejectConfirmation(index),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: getStatusColor(leave['status']),
                              radius: 5,
                            ),
                            SizedBox(width: 10),
                            CustomTitleText9(text: leave['status']),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }
}
