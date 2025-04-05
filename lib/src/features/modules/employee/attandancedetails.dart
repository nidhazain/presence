import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/common/tokenservice.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Employee {
  final String name;
  final int workDays;
  final int approvedLeaves;
  final String totalOvertime;
  // Add other properties as needed

  Employee({
    required this.name,
    required this.workDays,
    required this.approvedLeaves,
    required this.totalOvertime,
  });
}

class AttendanceDetailScreen extends StatefulWidget {
  // No longer strictly required since the backend now uses request.user,
  // but kept here if needed elsewhere.
  final Employee employee;

  const AttendanceDetailScreen({
    Key? key,
    required this.employee,
  }) : super(key: key);

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  late String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  List<Map<String, dynamic>> attendanceRecords = [];
  Map<String, dynamic> employeeDetails = {};
  Map<String, dynamic> attendanceSummary = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAttendanceDetails();
  }

  Future<void> _fetchAttendanceDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

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
        final data = json.decode(response.body);
        setState(() {
          employeeDetails = data['employee_details'] ?? {};
          attendanceRecords =
              List<Map<String, dynamic>>.from(data['attendance_records'] ?? []);
          attendanceSummary = data['attendance_summary'] ?? {};
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load attendance details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading data. Please try again.';
      });
    }
  }

  String _formatOvertime(dynamic overtime) {
    if (overtime == 0 || overtime == null) return '-';
    return '$overtime hr${(overtime is num && overtime > 1) ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Attendance', style: TextStyle(color: Colors.white)),
        backgroundColor: primary,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                _buildSummaryCard(
                                  'Present',
                                  attendanceSummary['present']?.toString() ??
                                      '0',
                                  Colors.green,
                                ),
                                _buildSummaryCard(
                                  'Absent',
                                  attendanceSummary['absent']?.toString() ??
                                      '0',
                                  Colors.red,
                                ),
                                _buildSummaryCard(
                                  'Late',
                                  attendanceSummary['late']?.toString() ?? '0',
                                  Colors.amber,
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Attendance',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                // Instead of mapping, use ListView.separated:
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: attendanceRecords.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                          height:
                                              10), // spacing between each tile
                                  itemBuilder: (context, index) =>
                                      _buildAttendanceItem(
                                          attendanceRecords[index]),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceItem(Map<String, dynamic> record) {
    final bool isPresent =
        record['status'] == 'Present' || record['status'] == 'Late';
    final Color statusColor = isPresent ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: Colors.red,
            width: 3,
          ),
        ),
      ),
      clipBehavior: Clip.hardEdge, // Ensures the borderRadius is respected
      child: IntrinsicHeight(
        // Makes the Container shrink to fit the Card
        child: Card(
          margin: EdgeInsets.zero, // Remove margin to avoid extra spacing
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              children: [
                Text(
                  record['date'] ?? 'No date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    record['status'] ?? 'Unknown',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Check-In: ${record['check_in'] ?? '-'}'),
                    Text('Check-Out: ${record['check_out'] ?? '-'}'),
                  ],
                ),
                SizedBox(height: 4),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //         'Hours: ${record['total_hours']?.toString().split('.').first ?? '0'}'),
                //     Text('OT: ${_formatOvertime(record['total_overtime'])}'),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
