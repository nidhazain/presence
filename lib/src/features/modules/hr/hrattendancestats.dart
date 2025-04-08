import 'package:flutter/material.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/common/tokenservice.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:presence/src/features/modules/hr/hrempcard.dart';
import 'package:presence/src/features/modules/hr/hremployeedetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Employee {
  final int empId;
  final String empNum;
  final String name;
  final String? designation;
  final String? community;
  final int workDays;
  final int absentDays;
  final int approvedLeaves;
  final String totalOvertime;
  final String? imageUrl;

  Employee({
    required this.empId,
    required this.empNum,
    required this.name,
    this.designation,
    this.community,
    required this.workDays,
    required this.absentDays,
    required this.approvedLeaves,
    required this.totalOvertime,
    this.imageUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empId: json['emp_id'],
      empNum: json['emp_num'],
      name: json['name'],
      designation: json['designation'],
      community: json['community'],
      workDays: json['work_days'],
      absentDays: json['absent_days'],
      approvedLeaves: json['approved_leaves'],
      totalOvertime: json['total_overtime'],
      imageUrl: json['image'],
    );
  }
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late int selectedMonth = DateTime.now().month;
  late int selectedYear = DateTime.now().year;
  List<Employee> employees = [];
  bool isLoading = true;
  String errorMessage = '';

  // List of months for the dropdown
  final List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Calculate date range for the selected month/year
      final firstDay = DateTime(selectedYear, selectedMonth, 1);
      final lastDay = DateTime(selectedYear, selectedMonth + 1, 0);
      
      final startDate = DateFormat('yyyy-MM-dd').format(firstDay);
      final endDate = DateFormat('yyyy-MM-dd').format(lastDay);

      // Replace with your actual API endpoint
      final url = Uri.parse('$BASE_URL/attendancedashboard/?start_date=$startDate&end_date=$endDate');
      await TokenService.ensureAccessToken();
      String? token = await TokenService.getAccessToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add auth if needed
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final employeeData = data['employees'] as List;
        
        setState(() {
          employees = employeeData.map((emp) => Employee.fromJson(emp)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load attendance data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Monthly Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _buildCompactMonthDropdown(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return AttendanceCard(
                    employee: employee,
                    index: index,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeDetailScreen(employee: employee),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: primary),
        borderRadius: BorderRadius.circular(20),
      ),
      constraints: const BoxConstraints(maxWidth: 100),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedMonth,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          isDense: true,
          menuMaxHeight: 300,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          items: List.generate(12, (index) {
            return DropdownMenuItem<int>(
              value: index + 1,
              child: Text('${months[index]} '),
            );
          }),
          onChanged: (int? value) {
            if (value != null) {
              setState(() {
                selectedMonth = value;
              });
              _fetchAttendanceData();
            }
          },
        ),
      ),
    );
  }

}

