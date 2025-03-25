import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class LeaveCancellationRequestList extends StatefulWidget {
  @override
  _LeaveCancellationRequestListState createState() => _LeaveCancellationRequestListState();
}

class _LeaveCancellationRequestListState extends State<LeaveCancellationRequestList> {
  List<Map<String, dynamic>> leaveRequests = [
    {
      'leaveType': 'Casual Leave',
      'startDate': '2025-03-15',
      'endDate': '2025-03-16',
      'reason': 'Family function',
      'cancelReason': 'Plans changed',
      'status': 'pending',
      'rejectReason': '',
    },
    {
      'leaveType': 'Earned Leave',
      'startDate': '2025-04-05',
      'endDate': '2025-04-10',
      'reason': 'Vacation trip',
      'cancelReason': 'Rescheduled',
      'status': 'pending',
      'rejectReason': '',
    },
    {
      'leaveType': 'Restricted Leave',
      'startDate': '2025-05-01',
      'endDate': '2025-05-01',
      'reason': 'Festival',
      'cancelReason': 'Work commitments',
      'status': 'pending',
      'rejectReason': '',
    },
  ];

  final TextEditingController _rejectReasonController = TextEditingController();

  // Format date from yyyy-MM-dd to dd MMM yyyy
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  void updateStatus(int index, String newStatus, {String rejectReason = ''}) {
    setState(() {
      leaveRequests[index]['status'] = newStatus;
      if (newStatus == 'rejected') {
        leaveRequests[index]['rejectReason'] = rejectReason;
      }
    });
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

  void showCancellationDetailsDialog(BuildContext context, Map<String, dynamic> request) {
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
                CustomTitleText10(text: "Leave Type:"),
                textfield(data: request['leaveType']),
                CustomTitleText10(text: "Period:"),
                textfield(data: "${formatDate(request['startDate'])} - ${formatDate(request['endDate'])}"),
                CustomTitleText10(text: "Reason for Leave:"),
                textfield(data: request['reason']),
                CustomTitleText10(text: "Reason for Cancellation:"),
                textfield(data: request['cancelReason']),
                if (request['status'] != 'pending') ...[
                  CustomTitleText10(text: "Status:"),
                  textfield(
                    data: request['status'].toUpperCase(),
                  ),
                ],
                if (request['status'] == 'rejected' &&
                    request['rejectReason'] != null &&
                    request['rejectReason'].isNotEmpty) ...[
                  CustomTitleText10(text: "Rejection Reason:"),
                  textfield(data: request['rejectReason']),
                ],
                if (request['imageUrl'] != null && request['imageUrl'].isNotEmpty) ...[
                  CustomTitleText10(text: "Attachment:"),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showFullSizeImage(context, request['imageUrl']),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          request['imageUrl'],
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

  void showRejectConfirmation(int index) {
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
                updateStatus(index, 'rejected', rejectReason: _rejectReasonController.text);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void sortRequests() {
    leaveRequests.sort((a, b) {
      if (a['status'] == 'pending' && b['status'] != 'pending') {
        return -1;
      } else if (a['status'] != 'pending' && b['status'] == 'pending') {
        return 1;
      }
      return 0;
    });
  }

  Color getStatusColor(String status) {
    if (status == 'accepted') return dgreen;
    if (status == 'rejected') return red;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    sortRequests();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          AppBar(title: CustomTitleText8(text: 'Cancellation Requests'), backgroundColor: Colors.white),
      body: ListView.separated(
        itemCount: leaveRequests.length,
        separatorBuilder: (context, index) => Divider(height: 1), 
        itemBuilder: (context, index) {
          final request = leaveRequests[index];
          return GestureDetector(
            onTap: () => showCancellationDetailsDialog(context, request),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTitleText10(text: request['leaveType']),
                      SizedBox(height: 5),
                      CustomTitleText20(
                          text: "${formatDate(request['startDate'])} - ${formatDate(request['endDate'])}")
                    ],
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: getStatusColor(request['status']),
                        radius: 5,
                      ),
                      SizedBox(width: 10),
                      if (request['status'] != 'pending')
                        CustomTitleText9(text: request['status']),
                      if (request['status'] == 'pending') ...[
                        IconButton(
                          icon: Icon(Icons.check, color: dgreen),
                          onPressed: () => updateStatus(index, 'accepted'),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: red),
                          onPressed: () => showRejectConfirmation(index),
                        ),
                      ],
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