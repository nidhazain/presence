import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/leaveendpoint.dart';

class LeaveRequestPage extends StatefulWidget {
  @override
  _LeaveRequestPageState createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final apiEndpoints = ApiEndpoints();
  List<Map<String, dynamic>> leaveRequests = [];
  bool isLoading = true;
  String errorMessage = '';
  
  final TextEditingController _rejectReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPendingLeaveRequests();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.file_copy_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No Pending Leave Requests',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'All leave requests have been processed or there are no new requests',
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

  Future<void> _fetchPendingLeaveRequests() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      await TokenService.ensureAccessToken();
      final token = await TokenService.getAccessToken();
      final response = await http.get(
        Uri.parse(apiEndpoints.pendingLeaveRequests),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          leaveRequests = data.map((leave) {
            return {
              'id': leave['id'],
              'type': leave['leave_type'],
              'startDate': leave['start_date'],
              'endDate': leave['end_date'],
              'reason': leave['reason'],
              'status': leave['status'].toLowerCase(),
              'rejectReason': leave['reject_reason'] ?? '',
              'attachmentUrl': leave['attachment_url'] ?? '',
              'employeeName': leave['employee_name'] ?? '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load leave requests: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching leave requests: $e';
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

  Color getStatusColor(String status) {
    if (status == 'approved') return dgreen;
    if (status == 'rejected') return red;
    return Colors.orange;
  }

  Future<void> updateLeaveStatus(int leaveId, String action, {String rejectReason = ''}) async {
    try {
      await TokenService.ensureAccessToken();
      final token = await TokenService.getAccessToken();
      final response = await http.post(
        Uri.parse('${apiEndpoints.approveRejectLeave}$leaveId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': action,
          'reject_reason': rejectReason,
        }),
      );

      if (response.statusCode == 200) {
        // Refresh the list after successful update
        await _fetchPendingLeaveRequests();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave ${action}d successfully!')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update leave status: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating leave status: $e')),
      );
    }
  }

  void showRejectConfirmation(int leaveId) {
    _rejectReasonController.clear();

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
              Text("Are you sure you want to reject this leave request?"),
              SizedBox(height: 16),
              TextField(
                controller: _rejectReasonController,
                decoration: InputDecoration(
                  labelText: "Reason for rejection",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            CustomButton(
              text: 'confirm',
              onPressed: () {
                updateLeaveStatus(leaveId, 'reject', 
                  rejectReason: _rejectReasonController.text);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
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

  void showLeaveDetailsDialog(Map<String, dynamic> leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTitleText8(text: 'Leave Details'),
            CloseButton(onPressed: () => Navigator.pop(context)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leave['employeeName'] != null) ...[
                  CustomTitleText10(text: "Employee:"),
                  textfield(data: leave['employeeName']),
                ],
                CustomTitleText10(text: "Leave Type:"),
                textfield(data: leave['type']),
                CustomTitleText10(text: "Period:"),
                textfield(
                  data: "${formatDate(leave['startDate'])} - ${formatDate(leave['endDate'])}"
                ),
                CustomTitleText10(text: "Reason:"),
                textfield(data: leave['reason']),
                if (leave['status'] != 'pending') ...[
                  CustomTitleText10(text: "Status:"),
                  textfield(data: leave['status'].toUpperCase()),
                ],
                if (leave['status'] == 'rejected' && 
                    leave['rejectReason'] != null && 
                    leave['rejectReason'].isNotEmpty) ...[
                  CustomTitleText10(text: "Rejection Reason:"),
                  textfield(data: leave['rejectReason']),
                ],
                if (leave['attachmentUrl'] != null && 
                    leave['attachmentUrl'].isNotEmpty) ...[
                  CustomTitleText10(text: "Attachment:"),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showFullSizeImage(context, leave['attachmentUrl']),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          leave['attachmentUrl'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Text('Failed to load image'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CustomTitleText8(text: 'Leave Requests'), 
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : leaveRequests.isEmpty
                  ? _buildEmptyState() 
                  : ListView.separated(
                      itemCount: leaveRequests.length,
                      separatorBuilder: (context, index) => Divider(
                          color: primary.withOpacity(.3), height: 1),
                      itemBuilder: (context, index) {
                        var leave = leaveRequests[index];
                        return GestureDetector(
                          onTap: () => showLeaveDetailsDialog(leave),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTitleText10(text: leave['type']),
                                      if (leave['employeeName'] != null)
                                        CustomTitleText20(text: leave['employeeName']),
                                      SizedBox(height: 5),
                                      CustomTitleText20(
                                        text: "${formatDate(leave['startDate'])} - ${formatDate(leave['endDate'])}"
                                      ),
                                    ],
                                  ),
                                ),
                                leave['status'] == 'pending'
                                    ? Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.check, color: dgreen),
                                            onPressed: () => updateLeaveStatus(
                                              leave['id'], 'approve'),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close, color: red),
                                            onPressed: () => showRejectConfirmation(leave['id']),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: getStatusColor(leave['status']),
                                            radius: 5,
                                          ),
                                          SizedBox(width: 10),
                                          CustomTitleText9(text: leave['status']),
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
