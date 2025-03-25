// import 'package:flutter/material.dart';
// import 'package:presence/src/common_pages/cancellation.dart';
// import 'package:presence/src/common_widget/custom_card.dart';
// import 'package:presence/src/common_widget/submitbutton.dart';
// import 'package:presence/src/common_widget/text_tile.dart';

// class Leave {
//   final String type;
//   final String startDate;
//   final String? endDate; // Make sure this line exists
//   final String status;
//   final String reason;

//   Leave({
//     required this.type,
//     required this.startDate,
//     this.endDate, // Ensure this field exists in the constructor
//     required this.status,
//     required this.reason,
//   });
// }

// void showLeaveDetailsDialog(BuildContext context, Map<String, dynamic> leave) {  
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text("Leave Details"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Type: ${leave['type']}", style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 5),
//             Text("Date: ${leave['date']}"),
//             SizedBox(height: 5),
//             Text("Reason: ${leave['reason']}"),
//             SizedBox(height: 10),
//             if (leave['status'] != 'pending')
//               Text("Status: ${leave['status'].toUpperCase()}",
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: leave['status'] == 'accepted' ? Colors.green : Colors.red)),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("Close")),
//         ],
//       );
//     },
//   );
// }
