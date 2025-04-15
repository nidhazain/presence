import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/features/api/common/tokenservice.dart';
import 'package:presence/src/features/api/url.dart';

class ManualAttendancePage extends StatefulWidget {
  @override
  _ManualAttendancePageState createState() => _ManualAttendancePageState();
}

class _ManualAttendancePageState extends State<ManualAttendancePage> {
  List<AttendanceRequest> requests = [];
  bool isLoading = true;
  String errorMessage = '';
  http.Client? _httpClient;
  StreamSubscription? _requestSubscription;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _fetchRequests();
  }

  @override
  void dispose() {
    _requestSubscription?.cancel();
    _httpClient?.close();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    try {
      final token = await TokenService.getAccessToken();
      final response = await _httpClient!.get(
        Uri.parse('$BASE_URL/attendance/requests/'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> requestsList = [];

        if (responseData is Map &&
            responseData.containsKey('pending_attendance_requests')) {
          requestsList = responseData['pending_attendance_requests'] ?? [];
        }

        if (mounted) {
          setState(() {
            requests = requestsList.map((item) {
              return AttendanceRequest.fromJson(item as Map<String, dynamic>);
            }).toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load: ${response.statusCode}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage =
              'Error: ${e is TimeoutException ? 'Request timed out' : e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateRequest(String action, AttendanceRequest request) async {
    try {
      final token = await TokenService.getAccessToken();
      final response = await _httpClient!
          .post(
            Uri.parse('$BASE_URL/attendance/requests/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              "id": request.id, 
              'action': action,
              //'reject_reason': reason ?? '',
            }),
          )
          .timeout(Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status updated successfully')),
          );
        }
        await _fetchRequests();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update status')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error: ${e is TimeoutException ? 'Request timed out' : 'Failed to update'}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (errorMessage.isNotEmpty) return Center(child: Text(errorMessage));
    if (requests.isEmpty) return Center(child: Text('No pending requests'));

    return Scaffold(
      appBar: AppBar(
        title: CustomTitleText8(text: 'Attendance Requests'),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRequests,
        child: ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: CustomTitleText10(text: request.employeeName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(' ${request.workType}'),
                    Text('Date: ${request.date}'),
                    // Text('Time: ${request.checkIn ?? '--'} to ${request.checkOut ?? '--'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () => _updateRequest('approve', request),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => _updateRequest('reject', request),
                    ),
                  ],
                ),
                onTap: () => _showDetailsDialog(request),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDetailsDialog(AttendanceRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request.employeeName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Work Type: '),
              textfield(data: '${request.workType}'),
              SizedBox(height: 10),
              Text('Date:'),
              textfield(data: '${request.date} '),
              SizedBox(height: 10),
              Text('Check-in: '),
              textfield(data: '${request.checkIn ?? 'Not recorded'}'),
              Text('Check-out: '),
              textfield(data: '${request.checkOut ?? 'Not recorded'}'),
              if (request.location != null) ...[
                SizedBox(height: 10),
                Text('Location:'),
                textfield(data: request.location!),
              ],
              if (request.image != null) ...[
                SizedBox(height: 15),
                Text('Proof:'),
                SizedBox(height: 5),
                Image.network(request.image!, height: 200),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class AttendanceRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String date;
  final String workType;
  final String? checkIn;
  final String? checkOut;
  final String? image;
  final String? location; 

  AttendanceRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.workType,
    this.checkIn,
    this.checkOut,
    this.image,
    this.location,
  });

  factory AttendanceRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceRequest(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? 'Unknown',
      date: json['date']?.toString() ?? '',
      workType: json['work_type']?.toString() ?? 'Not specified',
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      image: json['image']?.toString(),
      location: json['location']?.toString(), 
    );
  }
}
