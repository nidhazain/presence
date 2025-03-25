import 'package:flutter/material.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/modules/hr/hrempcard.dart';
import 'package:presence/src/features/modules/hr/hremployeedetails.dart';

class Employee {
  final String name;
  final int workDays;
  final int leaves;
  final String overtime;

  Employee({
    required this.name,
    required this.workDays,
    required this.leaves,
    required this.overtime,
  });
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Get current month and year
  late int selectedMonth = DateTime.now().month;
  //final int currentYear = DateTime.now().year;
  
  // List of months for the dropdown
  final List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  final List<Employee> employees = [
    Employee(name: 'Shana Yasmin', workDays: 26, leaves: 0, overtime: '2 hrs'),
    Employee(name: 'Farha Cheroor', workDays: 21, leaves: 4, overtime: '6 hrs'),
    Employee(name: 'Jadeera P', workDays: 26, leaves: 0, overtime: '-'),
    Employee(name: 'Nishida', workDays: 25, leaves: 1, overtime: '-'),
    Employee(name: 'Huda Fathima', workDays: 20, leaves: 4, overtime: '-'),
    Employee(name: 'Riswana', workDays: 24, leaves: 2, overtime: '1 hr'),
  ];

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
                    _buildCompactMonthDropdown(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
      constraints: const BoxConstraints(maxWidth: 130),
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
            }
          },
        ),
      ),
    );
  }
}