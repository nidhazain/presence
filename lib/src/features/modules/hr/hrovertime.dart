import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/common/tokenservice.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:presence/src/features/modules/hr/hremployeeovertime.dart';

// Models
class OvertimeRecord {
  final int employeeId;
  final String employeeName;
  final String designation;
  final double totalOvertime;

  OvertimeRecord({
    required this.employeeId,
    required this.employeeName,
    required this.designation,
    required this.totalOvertime,
  });

  factory OvertimeRecord.fromJson(Map<String, dynamic> json) {
    return OvertimeRecord(
      employeeId: json['employee_id'] as int? ?? 0,
      employeeName: json['name'] as String? ?? 'Unknown',
      designation: json['designation'] as String? ?? 'N/A',
      totalOvertime: (json['total_overtime'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EmployeeOvertimeDetail {
  final String name;
  final String designation;
  final String department;
  final double totalOvertime;
  final List<OvertimeHistoryItem> overtimeHistory;

  EmployeeOvertimeDetail({
    required this.name,
    required this.designation,
    required this.department,
    required this.totalOvertime,
    required this.overtimeHistory,
  });

  factory EmployeeOvertimeDetail.fromJson(Map<String, dynamic> json) {
    return EmployeeOvertimeDetail(
      name: json['name'] as String? ?? 'Unknown',
      designation: json['designation'] as String? ?? 'N/A',
      department: json['department'] as String? ?? 'N/A',
      totalOvertime: (json['total_overtime'] as num?)?.toDouble() ?? 0.0,
      overtimeHistory: (json['overtime_history'] as List<dynamic>?)
              ?.map((item) => OvertimeHistoryItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OvertimeHistoryItem {
  final String date;
  final double hours;
  final String reason;
  final String status;

  OvertimeHistoryItem({
    required this.date,
    required this.hours,
    required this.reason,
    required this.status
  });

  factory OvertimeHistoryItem.fromJson(Map<String, dynamic> json) {
    return OvertimeHistoryItem(
      date: json['date'] as String? ?? 'N/A',
      hours: (json['assigned_hours'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? 'N/A',
      status: json['status']
    );
  }
}

// Pages
class Hrovertime extends StatefulWidget {
  @override
  _HrovertimeState createState() => _HrovertimeState();
}

class _HrovertimeState extends State<Hrovertime> {
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  List<OvertimeRecord> overtimeRecords = [];
  bool isLoading = true;
  String errorMessage = '';

  final List<Color> avatarColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    fetchOvertimeData();
  }

  Future<void> fetchOvertimeData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await TokenService.ensureAccessToken();
      final String? token = await TokenService.getAccessToken();
      final response = await http.get(
        Uri.parse('$BASE_URL/overtimeoverview/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          overtimeRecords = (responseData["employees_overtime"] as List)
              .map((json) => OvertimeRecord.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data: ${e.toString()}';
      });
    }
  }

  List<OvertimeRecord> get filteredRecords {
    return overtimeRecords.where((record) {
      return record.employeeName
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }

  void navigateToEmployeeDetail(int employeeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeOvertimeDetailPage(employeeId: employeeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                hintText: 'Search by employee name...',
                prefixIcon: Icon(Icons.search, color: primary.withOpacity(.5)),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : filteredRecords.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No overtime records found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchOvertimeData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = filteredRecords[index];
                                final avatarColor = avatarColors[index % avatarColors.length];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    onTap: () => navigateToEmployeeDetail(record.employeeId),
                                    leading: CircleAvatar(
                                      backgroundColor: avatarColor,
                                      child: Text(
                                        record.employeeName.substring(0, 1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(record.employeeName),
                                    subtitle: Text(record.designation),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${record.totalOvertime.toStringAsFixed(1)} hrs',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

