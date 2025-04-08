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

  Employee({
    required this.name,
    required this.workDays,
    required this.approvedLeaves,
    required this.totalOvertime,
  });
}

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
  Map<String, dynamic> employeeDetails = {};
  Map<String, dynamic> attendanceSummary = {};
  bool isLoading = true;
  bool isLoadingMore = false;
  String errorMessage = '';
  
  // Pagination variables
  int currentPage = 1;
  int itemsPerPage = 10;
  bool hasMoreData = true;
  int totalRecords = 0;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceDetails();
  }

  Future<void> _fetchAttendanceDetails({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreData || isLoadingMore) return;
      setState(() {
        isLoadingMore = true;
      });
      currentPage++;
    } else {
      setState(() {
        isLoading = true;
        errorMessage = '';
        currentPage = 1;
        attendanceRecords = [];
        hasMoreData = true;
        totalRecords = 0;
      });
    }

    try {
      final url = Uri.parse('$BASE_URL/empattendoverview/?page=$currentPage&per_page=$itemsPerPage');
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
        final newRecords = List<Map<String, dynamic>>.from(data['attendance_records'] ?? []);
        
        // Get total records count from API if available
        final totalFromApi = data['total_records'] ?? data['meta']?['total'] ?? 0;
        
        setState(() {
          if (!loadMore) {
            employeeDetails = data['employee_details'] ?? {};
            attendanceSummary = data['attendance_summary'] ?? {};
            totalRecords = totalFromApi is int ? totalFromApi : 0;
          }
          
          attendanceRecords.addAll(newRecords);
          
          // More accurate way to check if we've reached the end
          if (totalRecords > 0) {
            // If we have total records info from API
            hasMoreData = attendanceRecords.length < totalRecords;
          } else {
            // Fallback: check if we got fewer items than requested
            hasMoreData = newRecords.length >= itemsPerPage;
          }
          
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        throw Exception('Failed to load attendance details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
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
      backgroundColor: Colors.white,
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
              : NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    // Load more when scrolled to bottom
                    if (scrollNotification is ScrollEndNotification &&
                        scrollNotification.metrics.extentAfter == 0 &&
                        hasMoreData &&
                        !isLoadingMore) {
                      _fetchAttendanceDetails(loadMore: true);
                      return true;
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
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
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: attendanceRecords.length + (hasMoreData ? 1 : 0),
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      if (index >= attendanceRecords.length) {
                                        return _buildLoadMoreIndicator();
                                      }
                                      return _buildAttendanceItem(
                                          attendanceRecords[index]);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: isLoadingMore
            ? CircularProgressIndicator()
            : hasMoreData
                ? ElevatedButton(
                    onPressed: () => _fetchAttendanceDetails(loadMore: true),
                    child: Text('Load More'),
                  )
                : Text(
                    'No more records to load',
                    style: TextStyle(color: Colors.grey),
                  ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: Colors.white,
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
      clipBehavior: Clip.hardEdge, 
      child: IntrinsicHeight(
        child: Card(
          color: Colors.white,
          margin: EdgeInsets.zero, 
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}