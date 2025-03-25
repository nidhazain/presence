import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/modules/hr/hrassignovertime.dart';

class Employee {
  final String id;
  final String name;
  final String department;
  final String profileImage;
  final List<OvertimeRecord> overtimeRecords;

  Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.profileImage,
    required this.overtimeRecords,
  });
}

class OvertimeRecord {
  final DateTime date;
  final double hours;
  final String description;

  OvertimeRecord({
    required this.date,
    required this.hours,
    required this.description,
  });
}

class Hrovertime extends StatefulWidget {
  @override
  _HrovertimeState createState() => _HrovertimeState();
}

class _HrovertimeState extends State<Hrovertime> {
  DateTime selectedMonth = DateTime.now();
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  // List of colors for avatars
  final List<Color> avatarColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  // List of month options for dropdown
  final List<Map<String, dynamic>> months = [
    {'name': 'January', 'value': 1},
    {'name': 'February', 'value': 2},
    {'name': 'March', 'value': 3},
    {'name': 'April', 'value': 4},
    {'name': 'May', 'value': 5},
    {'name': 'June', 'value': 6},
    {'name': 'July', 'value': 7},
    {'name': 'August', 'value': 8},
    {'name': 'September', 'value': 9},
    {'name': 'October', 'value': 10},
    {'name': 'November', 'value': 11},
    {'name': 'December', 'value': 12},
  ];

  // Sample data
  final List<Employee> employees = [
    Employee(
      id: 'EMP001',
      name: 'John Smith',
      department: 'Engineering',
      profileImage: 'assets/profile1.jpg',
      overtimeRecords: [
        OvertimeRecord(
          date: DateTime(2025, 3, 5),
          hours: 2.5,
          description: 'Server maintenance',
        ),
        OvertimeRecord(
          date: DateTime(2025, 3, 12),
          hours: 1.5,
          description: 'Urgent bug fix',
        ),
        OvertimeRecord(
          date: DateTime(2025, 2, 20),
          hours: 3.0,
          description: 'Release preparation',
        ),
      ],
    ),
    Employee(
      id: 'EMP002',
      name: 'Sarah Johnson',
      department: 'Marketing',
      profileImage: 'assets/profile2.jpg',
      overtimeRecords: [
        OvertimeRecord(
          date: DateTime(2025, 3, 8),
          hours: 2.0,
          description: 'Campaign planning',
        ),
        OvertimeRecord(
          date: DateTime(2025, 3, 10),
          hours: 3.5,
          description: 'Product launch',
        ),
        OvertimeRecord(
          date: DateTime(2025, 2, 15),
          hours: 1.0,
          description: 'Social media content',
        ),
      ],
    ),
    Employee(
      id: 'EMP003',
      name: 'Michael Chen',
      department: 'Finance',
      profileImage: 'assets/profile3.jpg',
      overtimeRecords: [
        OvertimeRecord(
          date: DateTime(2025, 3, 7),
          hours: 4.0,
          description: 'End of month reporting',
        ),
        OvertimeRecord(
          date: DateTime(2025, 2, 28),
          hours: 3.0,
          description: 'Quarterly review',
        ),
      ],
    ),
    Employee(
      id: 'EMP004',
      name: 'Emily Rodriguez',
      department: 'Customer Support',
      profileImage: 'assets/profile4.jpg',
      overtimeRecords: [
        OvertimeRecord(
          date: DateTime(2025, 3, 6),
          hours: 2.0,
          description: 'System outage support',
        ),
        OvertimeRecord(
          date: DateTime(2025, 3, 11),
          hours: 1.5,
          description: 'Customer escalation',
        ),
        OvertimeRecord(
          date: DateTime(2025, 2, 25),
          hours: 2.5,
          description: 'Training new staff',
        ),
      ],
    ),
  ];

  List<Employee> get filteredEmployees {
    return employees.where((employee) {
      final nameMatches =
          employee.name.toLowerCase().contains(searchQuery.toLowerCase());
      final idMatches =
          employee.id.toLowerCase().contains(searchQuery.toLowerCase());
      final departmentMatches =
          employee.department.toLowerCase().contains(searchQuery.toLowerCase());

      return nameMatches || idMatches || departmentMatches;
    }).toList();
  }

  List<OvertimeRecord> getFilteredRecords(Employee employee) {
    return employee.overtimeRecords.where((record) {
      // Only filter by month, ignoring year
      return record.date.month == selectedMonth.month;
    }).toList();
  }

  double getTotalOvertime(Employee employee) {
    final records = getFilteredRecords(employee);
    return records.fold(0, (sum, record) => sum + record.hours);
  }

  // Method to add new overtime record
  void addOvertimeRecord(Employee employee, OvertimeRecord record) {
    setState(() {
      // In a real app, you would update the database here
      employee.overtimeRecords.add(record);
    });
  }

  // Method to navigate to overtime assignment page
  void navigateToAssignOvertime() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: 600, maxWidth: 500),
            child: AssignOvertimePage(
              employees: employees,
              onAssign: (Employee employee, OvertimeRecord record) {
                addOvertimeRecord(employee, record);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 36,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: primary),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedMonth.month,
                              isDense: true,
                              icon: Icon(Icons.arrow_drop_down, size: 20),
                              elevation: 2,
                              style: TextStyle(color: primary, fontSize: 14),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedMonth =
                                        DateTime(selectedMonth.year, newValue);
                                  });
                                }
                              },
                              items: months.map<DropdownMenuItem<int>>(
                                  (Map<String, dynamic> month) {
                                return DropdownMenuItem<int>(
                                  value: month['value'],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Text(month['name']),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: navigateToAssignOvertime,
                          icon: Icon(Icons.add, color: primary),
                          label: Text(
                            'Assign Overtime',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        hintText: 'Search employees...',
                        prefixIcon:
                            Icon(Icons.search, color: primary.withOpacity(.5)),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredEmployees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No employees found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = filteredEmployees[index];
                          final records = getFilteredRecords(employee);
                          final totalHours = getTotalOvertime(employee);
                          final avatarColor =
                              avatarColors[index % avatarColors.length];

                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: avatarColor,
                                child: Text(
                                  employee.name.substring(0, 1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: CustomTitleText10(text: employee.name),
                              subtitle: Row(
                                children: [
                                  CustomTitleText9(text: employee.department),
                                  SizedBox(width: 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: totalHours > 0
                                          ? Colors.blue[100]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${totalHours.toStringAsFixed(1)} hrs',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: totalHours > 0
                                            ? Colors.blue[800]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                if (records.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'No overtime records for ${months.firstWhere((m) => m['value'] == selectedMonth.month)['name']}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: records.map((record) {
                                      return ListTile(
                                        dense: true,
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              DateFormat('dd')
                                                  .format(record.date),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          record.description,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        trailing: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${record.hours.toStringAsFixed(1)} hrs',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                        ),
                                        subtitle: Text(
                                          DateFormat('EEE, MMM d, yyyy')
                                              .format(record.date),
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
