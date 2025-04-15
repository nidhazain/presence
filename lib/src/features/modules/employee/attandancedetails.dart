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
  
  int currentPage = 1;
  final int itemsPerPage = 10;
  bool hasMoreData = true;
  int totalRecords = 0;
  

  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceDetails();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore && 
        hasMoreData &&
        !_isScrolling) {
      setState(() => _isScrolling = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.position.pixels >= 
            _scrollController.position.maxScrollExtent - 200) {
          _fetchAttendanceDetails(loadMore: true);
        }
        setState(() => _isScrolling = false);
      });
    }
  }

  Future<void> _fetchAttendanceDetails({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreData || isLoadingMore) return;
      setState(() => isLoadingMore = true);
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
        final totalFromApi = data['total_records'] ?? data['meta']?['total'] ?? 0;
        
        setState(() {
          if (!loadMore) {
            employeeDetails = data['employee_details'] ?? {};
            attendanceSummary = data['attendance_summary'] ?? {};
            totalRecords = totalFromApi is int ? totalFromApi : 0;
          }
          
          attendanceRecords.addAll(newRecords);
          hasMoreData = newRecords.length == itemsPerPage;
          if (totalRecords > 0) {
            hasMoreData = attendanceRecords.length < totalRecords;
          }
          
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        throw Exception('Failed to load attendance details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        if (loadMore) currentPage--;
        isLoading = false;
        isLoadingMore = false;
        errorMessage = 'Error loading data: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  // String _formatOvertime(dynamic overtime) {
  //   if (overtime == 0 || overtime == null) return '-';
  //   return '$overtime hr${(overtime is num && overtime > 1) ? 's' : ''}';
  // }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchAttendanceDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreWidget() {
    if (isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Loading more...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    } else if (errorMessage.isNotEmpty && attendanceRecords.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: _buildErrorWidget(),
      );
    } else if (!hasMoreData && attendanceRecords.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'No more records',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Attendance', style: TextStyle(color: Colors.white)),
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty && attendanceRecords.isEmpty
              ? _buildErrorWidget()
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Attendance Summary',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildSummaryCard(
                                        'Present',
                                        attendanceSummary['present']?.toString() ?? '0',
                                        Colors.green,
                                      ),
                                      _buildSummaryCard(
                                        'Absent',
                                        attendanceSummary['absent']?.toString() ?? '0',
                                        Colors.red,
                                      ),
                                      _buildSummaryCard(
                                        'Late',
                                        attendanceSummary['late']?.toString() ?? '0',
                                        Colors.amber,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Recent Attendance',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: attendanceRecords.length,
                                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          return _buildAttendanceItem(attendanceRecords[index]);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            _buildLoadMoreWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
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
          padding: const EdgeInsets.symmetric(vertical: 16),
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
              const SizedBox(height: 4),
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
    final Color statusColor = record['status'] == 'Present' 
        ? Colors.green 
        : record['status'] == 'Late' 
            ? Colors.amber 
            : Colors.red;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: statusColor,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              children: [
                Text(
                  record['date'] ?? 'No date',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Check-In: ${record['check_in'] ?? '-'}'),
                    Text('Check-Out: ${record['check_out'] ?? '-'}'),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}