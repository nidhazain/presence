import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/leaveapi.dart';

class Leave {
  final int id;
  final String type;
  final String startDate;
  final String? endDate;
  final String status;
  final String reason;
  final String? imageUrl;

  Leave({
    required this.id,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.reason,
    this.imageUrl,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'],
      type: json['leave_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      status: json['status'] ?? 'Unknown',
      reason: json['reason'] ?? 'No reason provided',
      imageUrl: json['image'],
    );
  }
}

class LeaveHistory extends StatefulWidget {
  const LeaveHistory({super.key});

  @override
  State<LeaveHistory> createState() => _LeaveHistoryState();
}

class _LeaveHistoryState extends State<LeaveHistory> {
  late Future<List<Leave>> _leaveFuture;

  @override
  void initState() {
    super.initState();
    _leaveFuture = LeaveService.fetchLeaveHistory();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return dgreen;
      case 'rejected':
        return red;
      case 'cancel rejected':
        return red;
      case 'cancelled':
        return dgreen;
      case 'pending' && 'cancel pending':
      default:
        return orange;
    }
  }

  String _calculateLeaveDays(String start, String? end) {
    try {
      DateTime startDate = DateFormat('yyyy-MM-dd').parse(start);
      if (end == null || end.isEmpty) {
        return "1";
      }
      DateTime endDate = DateFormat('yyyy-MM-dd').parse(end);
      if (endDate.isBefore(startDate)) return "0";
      return (endDate.difference(startDate).inDays + 1).toString();
    } catch (e) {
      return "0";
    }
  }

  String formatDate(String dateStr) {
    try {
      final DateTime date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showFullSizeImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topRight,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text('Failed to load image'),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -16,
              right: -16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 16,
                child: IconButton(
                  icon: Icon(Icons.close, size: 16, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLeaveDetailsDialog(BuildContext context, Leave leave) {
    final String leaveDays =
        _calculateLeaveDays(leave.startDate, leave.endDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leave.type, style: TextStyle(fontWeight: FontWeight.bold)),
            CloseButton(
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTitleText10(text: "Status: "),
                textfield(data: leave.status),
                CustomTitleText10(text: "Date:"),
                textfield(
                  data: leave.endDate != null
                      ? "${formatDate(leave.startDate)} to ${formatDate(leave.endDate!)}"
                      : formatDate(leave.startDate),
                ),
                CustomTitleText10(text: "Number of Days:"),
                textfield(data: leaveDays),
                CustomTitleText10(text: "Reason:"),
                textfield(data: leave.reason),
                if (leave.imageUrl != null && leave.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () => _showFullSizeImage(context, leave.imageUrl!),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            leave.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
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
                  ),
                const SizedBox(height: 20),
                if (leave.status.toLowerCase() == 'pending')
                  CustomButton(
                    text: "Cancel Request",
                    onPressed: () => _showCancelConfirmation(context, leave),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, Leave leave) {
    TextEditingController _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: CustomTitleText8(text: 'Cancel Request?')),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to cancel this leave request?"),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: "Reason",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
              text: 'cancel',
              onPressed: () async {
                if (_reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a reason.")),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                bool result = await LeaveService.cancelLeaveRequest(
                  leave,
                  reason: _reasonController.text.trim(),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result
                          ? "Leave request cancelled!"
                          : "Failed to cancel leave request."),
                    ),
                  );
                }
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
        child: FutureBuilder<List<Leave>>(
          future: _leaveFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Show loading
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No leave history available'));
            }

            final leaveList = snapshot.data!;

            return ListView.separated(
              itemCount: leaveList.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade300,
              ),
              itemBuilder: (context, index) {
                final leave = leaveList[index];

                return GestureDetector(
                  onTap: () => showLeaveDetailsDialog(context, leave),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTitleText10(text: leave.type),
                            SizedBox(height: 5),
                            CustomTitleText20(
                                text: formatDate(leave.startDate)),
                          ],
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: getStatusColor(leave.status),
                              radius: 5,
                            ),
                            SizedBox(width: 10),
                            CustomTitleText9(text: leave.status),
                            if (leave.status.toLowerCase() == 'approved')
                              TextButton(
                                onPressed: () =>
                                    _showCancelConfirmation(context, leave),
                                child: Text("Cancel",
                                    style: TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
