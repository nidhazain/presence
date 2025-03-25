// import 'package:flutter/material.dart';
// import 'package:presence/src/features/api/employee/shiftapi.dart';

// class ShiftCalendarScreen extends StatefulWidget {
//   @override
//   _ShiftCalendarScreenState createState() => _ShiftCalendarScreenState();
// }

// class _ShiftCalendarScreenState extends State<ShiftCalendarScreen> {
//   List<dynamic> _shifts = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchShiftRoster();
//   }

//   Future<void> _fetchShiftRoster() async {
//     try {
//       final String rosterId = 'your-roster-id'; // Replace with the actual roster ID
//       final data = await ShiftService.fetchShiftData('1');
//       setState(() {
//         _shifts = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       debugPrint('Error fetching shift roster: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shift Calendar'),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _shifts.length,
//               itemBuilder: (context, index) {
//                 final shift = _shifts[index];
//                 return ListTile(
//                   title: Text(shift['employee']),
//                   subtitle: Text(
//                       '${shift['date']} - ${shift['shift']} (${shift['start_time']} - ${shift['end_time']})'),
//                 );
//               },
//             ),
//     );
//   }
// }