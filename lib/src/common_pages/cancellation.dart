

import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';

class Leave {
  final String type;
  final String date;
  String status;

  Leave({required this.type, required this.date, required this.status});
}

// Dummy Data (Replace with database fetch later)
final List<Leave> leaveList = [
  Leave(type: 'Sick Leave', date: '4-12-2024', status: 'pending'),
  Leave(type: 'Casual Leave', date: '11-12-2024', status: 'approved'),
  Leave(type: 'Earned Leave', date: '20-12-2024', status: 'rejected'),
  Leave(type: 'Sick Leave', date: '4-12-2024', status: 'pending'),
  Leave(type: 'Casual Leave', date: '11-12-2024', status: 'approved'),
  Leave(type: 'Earned Leave', date: '20-12-2024', status: 'rejected'),
];

class CancelApprovedLeavePage extends StatefulWidget {
  const CancelApprovedLeavePage({super.key});

  @override
  State<CancelApprovedLeavePage> createState() =>
      _CancelApprovedLeavePageState();
}

class _CancelApprovedLeavePageState extends State<CancelApprovedLeavePage> {
  late List<Leave> approvedLeaves;

  @override
  void initState() {
    super.initState();
    approvedLeaves = leaveList
        .where((leave) => leave.status == 'approved')
        .map((leave) => Leave(type: leave.type, date: leave.date, status: leave.status))
        .toList(); // Creating a separate list to avoid direct mutation
  }

  void cancelLeave(int index) {
    setState(() {
      approvedLeaves[index].status = 'cancelled';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
        child: approvedLeaves.isEmpty
            ? const Center(child: Text("No approved leaves to cancel."))
            : ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: screenHeight * 0.01),
                itemCount: approvedLeaves.length,
                itemBuilder: (context, index) {
                  final leave = approvedLeaves[index];
                  return Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTitleText10(text: leave.type),
                            SizedBox(height: screenHeight * 0.005),
                            CustomTitleText9(text: leave.date),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => cancelLeave(index),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: blue,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                          ),
                          child: CustomTitleText10(text: 'Cancel'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
