// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:presence/src/common_widget/submitbutton.dart';
// import 'package:presence/src/constants/colors.dart';
// import 'package:presence/src/features/modules/hr/hrovertime.dart';

// // Assign Overtime Page
// class AssignOvertimePage extends StatefulWidget {
//   final List<Employee> employees;
//   final Function(Employee, OvertimeRecord) onAssign;

//   AssignOvertimePage({
//     required this.employees,
//     required this.onAssign,
//   });

//   @override
//   _AssignOvertimePageState createState() => _AssignOvertimePageState();
// }

// class _AssignOvertimePageState extends State<AssignOvertimePage> {
//   Employee? selectedEmployee;
//   DateTime selectedDate = DateTime.now();
//   final TextEditingController hoursController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Assign Overtime',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: primary,
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),

//               // Employee dropdown
//               DropdownButtonFormField<Employee>(
//                 decoration: InputDecoration(
//                   labelText: 'Select Employee',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 ),
//                 value: selectedEmployee,
//                 validator: (value) {
//                   if (value == null) {
//                     return 'Please select an employee';
//                   }
//                   return null;
//                 },
//                 items: widget.employees.map((Employee employee) {
//                   return DropdownMenuItem<Employee>(
//                     value: employee,
//                     // child: Text('${employee.name} (${employee.department})'),
//                     child: Text('${employee.name} '),
//                   );
//                 }).toList(),
//                 onChanged: (Employee? newValue) {
//                   setState(() {
//                     selectedEmployee = newValue;
//                   });
//                 },
//               ),
//               SizedBox(height: 16),

//               // Date picker
//               InkWell(
//                 onTap: () async {
//                   final DateTime today = DateTime.now();
//                   final DateTime initialDate =
//                       selectedDate.isBefore(today) ? today : selectedDate;

//                   final DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: initialDate,
//                     firstDate: today, // Only allow today or future dates
//                     lastDate: DateTime(2025, 12, 31),
//                   );
//                   if (picked != null && picked != selectedDate) {
//                     setState(() {
//                       selectedDate = picked;
//                     });
//                   }

//                   if (picked != null && picked != selectedDate) {
//                     setState(() {
//                       selectedDate = picked;
//                     });
//                   }
//                 },
//                 child: InputDecorator(
//                   decoration: InputDecoration(
//                     labelText: 'Date',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(DateFormat('EEE, MMM d, yyyy').format(selectedDate)),
//                       Icon(Icons.calendar_today, size: 20),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),

//               // Hours input
//               TextFormField(
//                 controller: hoursController,
//                 decoration: InputDecoration(
//                   labelText: 'Hours',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   suffixText: 'hrs',
//                 ),
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter overtime hours';
//                   }
//                   final double? hours = double.tryParse(value);
//                   if (hours == null || hours <= 0) {
//                     return 'Please enter a valid number of hours';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),

//               // Description input
//               TextFormField(
//                 controller: descriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 ),
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a description';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 24),

//               // Submit button
//               CustomButton(
//                   text: 'Assign overtime',
//                   onPressed: () {
//                     // if (_formKey.currentState!.validate() &&
//                     //     selectedEmployee != null) {
//                     //   final double hours = double.parse(hoursController.text);
//                     //   final newRecord = OvertimeRecord(
//                     //     date: selectedDate,
//                     //     hours: hours,
//                     //     description: descriptionController.text,
//                     //   );
//                     //   widget.onAssign(selectedEmployee!, newRecord);
//                     // }
//                   })
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
