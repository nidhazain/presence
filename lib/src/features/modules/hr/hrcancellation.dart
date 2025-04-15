import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:presence/src/features/api/common/tokenservice.dart';
import 'package:presence/src/features/api/leaveendpoint.dart';

class LeaveCancellationRequestList extends StatefulWidget {
  @override
  _LeaveCancellationRequestListState createState() => _LeaveCancellationRequestListState();
}

class _LeaveCancellationRequestListState extends State<LeaveCancellationRequestList> {
  final apiEndpoints = ApiEndpoints();
  List<Map<String, dynamic>> cancellationRequests = [];
  bool isLoading = true;
  String errorMessage = '';
  
  final TextEditingController _rejectReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPendingCancellationRequests();
  }


  Future<void> _fetchPendingCancellationRequests() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      await TokenService.ensureAccessToken();
     final token = await TokenService.getAccessToken();
     print(token);
      final response = await http.get(
        Uri.parse(apiEndpoints.pendingCancellationRequests),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          cancellationRequests = data.map((request) {
            return {
              'id': request['id'],
              'leaveType': request['leave_type'] ?? 'Unknown',
              'startDate': request['start_date'] ?? '',
              'endDate': request['end_date'] ?? '',
              'reason': request['reason'] ?? 'Not specified',
              'cancelReason': request['cancellation_reason'] ?? 'no reason',
              'status': 'pending', 
              'employee': request['name'] ?? 'unknown' ,
              'image': request['image'] ?? '',
              'cancellation_reason' : request['cancellation_reason']
            };
          }).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 403) {
        setState(() {
          isLoading = false;
          errorMessage = 'Access denied. Only HR can view cancellation requests.';
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load cancellation requests: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching cancellation requests: $e';
      });
    }
  }

  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _handleCancellationDecision(int leaveId, String action) async {
    try {
      await TokenService.ensureAccessToken();
      final token = await TokenService.getAccessToken();
      final response = await http.post(
        
        Uri.parse('${apiEndpoints.approveRejectCancellation}$leaveId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        await _fetchPendingCancellationRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json.decode(response.body)['message']),
        ));
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json.decode(response.body)['error'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process request: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing request: $e')),
      );
    }
  }

  void _showFullSizeImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  void showCancellationDetailsDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTitleText8(text: 'Cancellation Request'),
            CloseButton(onPressed: () => Navigator.pop(context)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTitleText10(text: "Employee:"),
                textfield(data: request['employee']),
                CustomTitleText10(text: "Leave Type:"),
                textfield(data: request['leaveType']),
                CustomTitleText10(text: "Original Period:"),
                textfield(data: "${formatDate(request['startDate'])} - ${formatDate(request['endDate'])}"),
                CustomTitleText10(text: "Original Reason:"),
                textfield(data: request['reason']),
                CustomTitleText10(text: "Cancellation Reason:"),
                textfield(data: request['cancellation_reason']),
                if (request['image'] != null && request['image'].isNotEmpty) ...[
                  CustomTitleText10(text: "Attachment:"),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showFullSizeImage(context, request['image']),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          request['image'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Text('Failed to load attachment'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showRejectConfirmation(int leaveId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: CustomTitleText8(text: 'Confirm Rejection')),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to reject this cancellation request?"),
              SizedBox(height: 16),
              TextField(
                controller: _rejectReasonController,
                decoration: InputDecoration(
                  labelText: "Reason for rejection (optional)",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            CustomButton(
              text: 'Confirm Rejection',
              onPressed: () {
                _handleCancellationDecision(leaveId, 'reject');
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Color getStatusColor(String status) {
    if (status == 'cancelled') return dgreen;
    if (status == 'cancel rejected') return red;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CustomTitleText8(text: 'Pending Cancellation Requests'), 
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : cancellationRequests.isEmpty
                  ?Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_copy_outlined, 
                            size: 100, 
                            color: Colors.grey.shade300
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Pending Cancellation Requests',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 18,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'All leave cancellation requests have been processed',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: cancellationRequests.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final request = cancellationRequests[index];
                        return GestureDetector(
                          onTap: () => showCancellationDetailsDialog(request),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTitleText10(text: request['leaveType']),
                                      SizedBox(height: 4),
                                        CustomTitleText20(text: request['employee']),
                                      SizedBox(height: 4),
                                      CustomTitleText20(
                                        text: "${formatDate(request['startDate'])} - ${formatDate(request['endDate'])}"
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check, color: dgreen),
                                      onPressed: () => _handleCancellationDecision(request['id'], 'approve'),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: red),
                                      onPressed: () => showRejectConfirmation(request['id']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }
}

