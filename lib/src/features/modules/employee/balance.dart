import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/features/api/employee/balanceapi.dart';

class BalancePage extends StatefulWidget {
  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  late Future<List<LeaveBalanceModel>> leaveFuture;

  @override
  void initState() {
    super.initState();
    leaveFuture = BalanceService().fetchLeaveBalance();
  }

  // void showBalanceDetailsDialog(BuildContext context, LeaveBalanceModel leave) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(15),
  //       ),
  //       title: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           CustomTitleText8(text: leave.name),
  //           IconButton(
  //             icon: Icon(Icons.close, color: Colors.grey),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       ),
  //       content: leave.dates.isNotEmpty
  //           ? SizedBox(
  //               width: double.maxFinite,
  //               child: ListView.builder(
  //                 shrinkWrap: true,
  //                 itemCount: leave.dates.length,
  //                 itemBuilder: (context, index) {
  //                   final period = leave.dates[index];
  //                   final leavePeriod = period['end_date'] != null
  //                       ? "${period['start_date']} to ${period['end_date']}"
  //                       : period['start_date'];
  //                   return Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //                     child: textfield(
  //                       data: leavePeriod,
  //                     ),
  //                   );
  //                 },
  //               ),
  //             )
  //           : textfield(data: "No leave history available."),
  //     ),
  //   );
  // }
  void showBalanceDetailsDialog(BuildContext context, LeaveBalanceModel leave) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTitleText8(text: leave.name),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Text added here
          Text(
            'Status: ${leave.status}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          leave.dates.isNotEmpty
              ? SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: leave.dates.length,
                    itemBuilder: (context, index) {
                      final period = leave.dates[index];
                      final leavePeriod = period['end_date'] != null
                          ? "${period['start_date']} to ${period['end_date']}"
                          : period['start_date'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: textfield(
                          data: leavePeriod,
                        ),
                      );
                    },
                  ),
                )
              : textfield(data: "No leave history available."),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: FutureBuilder<List<LeaveBalanceModel>>(
          future: leaveFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading leave balances'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No leave balance data found.'));
            }

            final leaveList = snapshot.data!;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: size.width > 600 ? 3 : 2,
                crossAxisSpacing: size.width * 0.03,
                mainAxisSpacing: size.height * 0.02,
                childAspectRatio: size.width / (size.height * 0.4),
              ),
              itemCount: leaveList.length,
              itemBuilder: (context, index) {
                final leave = leaveList[index];
                return GestureDetector(
                  onTap: () => showBalanceDetailsDialog(context, leave),
                  child: LeaveCardDynamic(leave: leave),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class LeaveCardDynamic extends StatelessWidget {
  final LeaveBalanceModel leave;

  const LeaveCardDynamic({Key? key, required this.leave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final parts = leave.used.split(' ')[0].split('/');
    final used = double.tryParse(parts[0]) ?? 0;
    final total = parts[1] == '∞' ? double.infinity : double.tryParse(parts[1]) ?? 1;
    double progress = total.isFinite ? used / total : 0;

    Color progressColor;
    if (!total.isFinite) {
      progressColor = Colors.grey;
    } else if (progress == 1) {
      progressColor = Colors.red;
    } else if (progress >= 0.5) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width * 0.05),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: size.width * 0.02,
            spreadRadius: size.width * 0.005,
            offset: Offset(size.width * 0.02, size.width * 0.02),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTitleText8(text: leave.name),
          SizedBox(height: 10),
          CustomTitleText7(text: leave.used),
          if (total.isFinite)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: Duration(seconds: 1),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey.shade300,
                    color: progressColor,
                    minHeight: size.height * 0.007,
                    borderRadius: BorderRadius.circular(size.width * 0.02),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class LeaveBalanceModel {
  final String name;
  final String used;
  final List<dynamic> dates;
  final String status;

  LeaveBalanceModel({required this.name, required this.used, required this.dates,required this.status});

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      name: json['name'],
      used: json['used'],
      dates: json['dates'] ?? [],
      status : json['status'],
    );
  }
}
