import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/common/tokenservice.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:presence/src/features/modules/hr/hrattendancestats.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceDetailScreen extends StatefulWidget {
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
      final url =
          Uri.parse('$BASE_URL/employee/${widget.employee.empId}/attendance/');
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

        // Check if 'attendance_records' exists (not 'attendance')
        if (data['attendance_records'] != null) {
          setState(() {
            attendanceRecords = List<Map<String, dynamic>>.from(
                data['attendance_records']); // Updated key
            isLoading = false;
          });
        } else {
          setState(() {
            attendanceRecords = [];
            isLoading = false;
            errorMessage = "No attendance records found";
          });
        }
      } else {
        throw Exception(
            'Failed to load attendance details (Status: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  double _parseTotalHours(String totalHours) {
  try {
    if (totalHours.contains("day")) {
      // Handle cases like "-1 day, 15:00:00"
      final parts = totalHours.split(",");
      final dayPart = parts[0].trim(); // "-1 day"
      final timePart = parts[1].trim(); // "15:00:00"

      final days = double.parse(dayPart.split(" ")[0]); // -1
      final timeComponents = timePart.split(":");
      final hours = double.parse(timeComponents[0]); // 15
      final minutes = double.parse(timeComponents[1]); // 00

      return (days * 24) + hours + (minutes / 60);
    } else {
      // Handle cases like "9:00:00"
      final components = totalHours.split(":");
      final hours = double.parse(components[0]); // 9
      final minutes = double.parse(components[1]); // 00

      return hours + (minutes / 60);
    }
  } catch (e) {
    return 0.0; // Fallback if parsing fails
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomTitleText8(text: 'Attendance Summary'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTitleText20(text: currentMonth),
                ),
              ],
            ),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: primary.withOpacity(.5))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                        'Work Days', '${widget.employee.workDays} days'),
                    _buildSummaryRow(
                        'Leaves',
                        widget.employee.approvedLeaves == 0
                            ? '-'
                            : '${widget.employee.approvedLeaves} days'),
                    _buildSummaryRow('Overtime',
                        _formatOvertime(widget.employee.totalOvertime)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              )
            else if (attendanceRecords.isEmpty)
              const Text('No attendance records found')
            else
              ...attendanceRecords.map((record) => _buildAttendanceDetail(
  record['date'] ?? "No date",
  record['status'] == 'Present' || record['status'] == 'Late' 
      ? (record['check_in'] ?? "-") 
      : 'Leave',
  record['status'] == 'Present' || record['status'] == 'Late'
      ? (record['check_out'] ?? "-") 
      : 'Leave',
  record['status'] == 'Present' || record['status'] == 'Late',
  _parseTotalHours(record['total_hours'] ?? "0:00:00"), 
)).toList(),
          ],
        ),
      ),
    );
    
  }

  String _formatOvertime(String overtime) {
    if (overtime == '0:00' || overtime.isEmpty) return '-';

    try {
      final parts = overtime.split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        if (hours > 0) return '$hours hr${hours > 1 ? 's' : ''}';
      }
      return '-';
    } catch (e) {
      return '-';
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildAttendanceDetail(
  String date, 
  String checkIn, 
  String checkOut, 
  bool present,
  double totalHours, 
) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(date),
              const Spacer(),
              Text(present ? "Present" : "Absent"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text("Check-in: $checkIn"),
              const Spacer(),
              Text("Check-out: $checkOut"),
            ],
          ),
          const SizedBox(height: 8),
          Text("Total Hours: ${totalHours.toStringAsFixed(2)}"), // Display parsed hours
        ],
      ),
    ),
  );
}
}
