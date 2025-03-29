import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/common/tokenservice.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:presence/src/features/modules/hr/hrovertime.dart';
import 'package:http/http.dart' as http;

class EmployeeOvertimeDetailPage extends StatefulWidget {
  final int employeeId;

  const EmployeeOvertimeDetailPage({Key? key, required this.employeeId})
      : super(key: key);

  @override
  _EmployeeOvertimeDetailPageState createState() =>
      _EmployeeOvertimeDetailPageState();
}

class _EmployeeOvertimeDetailPageState
    extends State<EmployeeOvertimeDetailPage> {
  bool isLoading = true;
  String errorMessage = '';
  EmployeeOvertimeDetail? detail;

  @override
  void initState() {
    super.initState();
    fetchEmployeeDetail();
  }

  Future<void> fetchEmployeeDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await TokenService.ensureAccessToken();
      String? token = await TokenService.getAccessToken();
      final response = await http.get(
        Uri.parse('$BASE_URL/employee/overtime/${widget.employeeId}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          detail = EmployeeOvertimeDetail.fromJson(responseData);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load details: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: CustomTitleText(text: 'Overtime Details'),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _buildErrorView()
              : detail == null
                  ? const Center(child: Text('No details found'))
                  : _buildDetailView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: fetchEmployeeDetail,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee Profile Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${detail!.designation} • ${detail!.department}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer,
                        color: primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total: ${detail!.totalOvertime.toStringAsFixed(1)} hrs',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // History Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Overtime History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // History Cards
                ...detail!.overtimeHistory.map((item) => _buildHistoryCard(item)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(OvertimeHistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.date_range,
                color: primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${item.hours.toStringAsFixed(1)} hrs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}