import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';

class ManualAttendancePage extends StatefulWidget {
  @override
  _ManualAttendancePageState createState() => _ManualAttendancePageState();
}

class _ManualAttendancePageState extends State<ManualAttendancePage> {
  final List<ManualAttendance> attendances = [
    ManualAttendance(
      workType: "Field Work",
      date: "2025-03-12",
      startTime: "09:00 AM",
      endTime: "05:00 PM",
      proof: "New York, Times Square",
      isImage: false,
    ),
    ManualAttendance(
      workType: "Work From Home",
      date: "2025-03-10",
      startTime: "10:00 AM",
      endTime: "06:00 PM",
      proof: "images/pro.jpg",
      isImage: true,
    ),
  ];

  final Map<int, String> status = {};
  final Map<int, String> rejectionReasons = {};
void _showDetailsDialog(ManualAttendance attendance, int index) {
  String currentStatus = status[index] ?? "Pending";
  String? reason = rejectionReasons[index];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.all(16),
      content: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTitleText10(text: attendance.workType),
                  SizedBox(height: 10),
                  CustomTitleText10(text: "Date:"),
                  textfield(data: attendance.date),

                  CustomTitleText10(text: "Start Time:"),
                  textfield(data: attendance.startTime),

                  CustomTitleText10(text: "End Time:"),
                  textfield(data: attendance.endTime),

                  CustomTitleText10(text: "Attachment:"),
                  SizedBox(height: 10),
                  attendance.isImage
                      ? Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.3,
                            maxHeight: 200,
                          ),
                          child: Image.asset(
                            attendance.proof,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Text("Proof: ${attendance.proof}"),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: getStatusColor(currentStatus),
                        radius: 5,
                      ),
                      SizedBox(width: 10),
                      Text(
                        currentStatus,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(currentStatus)),
                      ),
                    ],
                  ),
                  if (currentStatus == "Rejected" &&
                      reason != null &&
                      reason.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Reason: $reason",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}



  void updateStatus(int index, String newStatus) {
    setState(() {
      status[index] = newStatus;
    });
  }

  void showRejectConfirmation(int index) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Rejection"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Please provide a reason for rejection."),
            SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter reason...",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Reject"),
            onPressed: () {
              setState(() {
                status[index] = "Rejected";
                rejectionReasons[index] = reasonController.text;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case "Accepted":
        return dgreen;
      case "Rejected":
        return red;
      default:
        return Colors.orange; // Pending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: CustomTitleText8(text: 'Attendance Requests'), backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: ListView.separated(
        itemCount: attendances.length,
        separatorBuilder: (context, index) => Divider(
            color: primary.withOpacity(.3),
            height: 1),
        itemBuilder: (context, index) {
          final attendance = attendances[index];
          return ListTile(
            title: CustomTitleText10(text: attendance.workType),
            subtitle: CustomTitleText20(text: attendance.date),
            trailing: status.containsKey(index)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: getStatusColor(status[index]),
                        radius: 5,
                      ),
                      SizedBox(width: 10),
                      CustomTitleText9(text: status[index]!)
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: dgreen),
                        onPressed: () => updateStatus(index, "Accepted"),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: red),
                        onPressed: () => showRejectConfirmation(index),
                      ),
                    ],
                  ),
            onTap: () => _showDetailsDialog(attendance, index),
          );
        },
      ),
    );
  }
}

class ManualAttendance {
  final String workType;
  final String date;
  final String startTime;
  final String endTime;
  final String proof;
  final bool isImage;

  ManualAttendance({
    required this.workType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.proof,
    required this.isImage,
  });
}
