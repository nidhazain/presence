import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';

class HrLeaveHistory extends StatefulWidget {
  const HrLeaveHistory({super.key});

  @override
  State<HrLeaveHistory> createState() => _HrLeaveHistoryState();
}

class _HrLeaveHistoryState extends State<HrLeaveHistory> {
  String _formatDate(String originalDate) {
    try {
      DateTime parsedDate = DateTime.parse(originalDate);
      
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return originalDate;
    }
  }

  Future<List<dynamic>> fetchLeaveHistory() async {
    String url = "$BASE_URL/leave-history/";
    await TokenService.ensureAccessToken();
    String? token = await TokenService.getAccessToken();
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load leave history: ${response.reasonPhrase}');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No Leave Records',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You have no leave records at the moment',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

void _showLeaveDetailsDialog(BuildContext context, Map<String, dynamic> leave) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: CustomTitleText8(text: '${leave['leave_type']}')),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Employee:'),
            textfield(data: '${leave['employee_name']}'),
            Text('Date:'),
            textfield(data: ' ${_formatDate(leave['start_date'])} - ${_formatDate(leave['end_date'])}'),
            Text('Reason:'),
            textfield(data: ' ${leave['reason']}'),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
            appBar: AppBar(
        title: CustomTitleText8(text: 'Approved Leave'), 
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchLeaveHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade300,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Leave History',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            final leaveData = snapshot.data!;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: 10,
              ),
              child: ListView.separated(
                itemCount: leaveData.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade300,
                ),
                itemBuilder: (context, index) {
                  final leave = leaveData[index];
                  return GestureDetector(
                    onTap: () => _showLeaveDetailsDialog(context, leave),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTitleText10(
                                  text: leave['employee_name'],
                                ),
                                const SizedBox(height: 5),
                                CustomTitleText10(
                                  text: leave['leave_type'],
                                ),
                              ],
                            ),
                          ),
                          
                          CustomTitleText20(
                            text: '${_formatDate(leave['start_date'])} - ${_formatDate(leave['end_date'])}'
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}