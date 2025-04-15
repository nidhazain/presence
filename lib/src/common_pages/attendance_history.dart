import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/attendanceapi.dart';

class Attendance {
  final int id;
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;
  final String workType;
  final String? location;
  final String? image;
  late final DateTime dateTime; // Add this field

  Attendance({
    required this.id,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.workType,
    this.location,
    this.image,
  }) {
    dateTime = DateFormat('yyyy-MM-dd').parse(date);
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      date: json['date'],
      checkIn: json['check_in'] ?? "",
      checkOut: json['check_out'] ?? "",
      status: json['status'] ?? "Pending",
      workType: json['work_type'] ?? "",
      location: json['location'],
      image: json['image'],
    );
  }
}

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  late Future<List<Attendance>> attendanceFuture;

  @override
  void initState() {
    super.initState();
    attendanceFuture = AttendanceService().fetchAttendanceRecords();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return green;
      case 'rejected':
        return red;
      case 'pending':
      default:
        return orange;
    }
  }

  String formatTime(String time) {
    try {
      DateTime dt = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("HH:mm").format(dt);
    } catch (e) {
      return time;
    }
  }

  void showAttendanceDetailsDialog(
    BuildContext context,
    Attendance attendance,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTitleText8(text: attendance.workType),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTitleText10(text: 'Date'),
              textfield(data: attendance.date),
              CustomTitleText10(text: 'Status'),
              textfield(data: attendance.status),
              CustomTitleText10(text: 'Time'),
              textfield(
                  data:
                      "${formatTime(attendance.checkIn)} to ${formatTime(attendance.checkOut)}"),
              CustomTitleText10(text: 'Work Type'),
              textfield(data: attendance.workType),
              if (attendance.location != null) ...[
                CustomTitleText10(text: 'Location'),
                textfield(data: attendance.location ?? ''),
              ],
              if (attendance.image != null) ...[
                CustomTitleText10(text: 'Image Proof'),
                GestureDetector(
                  onTap: () {
                    print("Image URL: ${attendance.image}");
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            InteractiveViewer(
                              child: Image.network(
                                attendance.image!,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint("Error loading image: $error");
                                  return Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                                fit: BoxFit.contain,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          attendance.image!,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint("Error loading image: $error");
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return FutureBuilder<List<Attendance>>(
    future: attendanceFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                'No Attendance Records',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your attendance history will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      // Sort the attendance list by date in descending order (newest first)
      final attendanceList = snapshot.data!..sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return ListView.separated(
        padding: const EdgeInsets.all(10),
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade300,
        ),
        itemCount: attendanceList.length,
        itemBuilder: (context, index) {
          final attendance = attendanceList[index];
          return GestureDetector(
            onTap: () => showAttendanceDetailsDialog(context, attendance),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(attendance.dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CustomTitleText10(text: attendance.workType),
                      const SizedBox(height: 5),
                      CustomTitleText20(
                        text:
                            "${formatTime(attendance.checkIn)} to ${formatTime(attendance.checkOut)}",
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: getStatusColor(attendance.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      CustomTitleText9(text: attendance.status),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
}
