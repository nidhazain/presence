import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_pages/leavedialog.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/leaveapi.dart';
import '../models/leave.dart';

class LeaveHistory extends StatefulWidget {
  const LeaveHistory({super.key});

  @override
  State<LeaveHistory> createState() => _LeaveHistoryState();
}

class _LeaveHistoryState extends State<LeaveHistory> {
  late Future<List<Leave>> _leaveFuture;
  final int _itemsPerPage = 5;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _leaveFuture = LeaveService.fetchLeaveHistory();
  }

  void _reloadLeaveHistory() {
    setState(() {
      _leaveFuture = LeaveService.fetchLeaveHistory();
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved' || 'accepted':
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

  String formatDate(String dateStr) {
    try {
      final DateTime date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Sorting function to sort leaves by id (descending)
  List<Leave> _sortLeavesById(List<Leave> leaves) {
    List<Leave> sortedLeaves = List.from(leaves);
    sortedLeaves.sort((a, b) => b.id.compareTo(a.id));
    return sortedLeaves;
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
              text: 'cancel request',
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

                  if (result) {
                    _reloadLeaveHistory();
                  }
                }
              })
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No Leave Records',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You have no leave records at the moment',
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

  Widget _buildPaginationControls(int totalItems, int currentPage) {
    final totalPages = (totalItems / _itemsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
        ),
        Text('Page $currentPage of $totalPages'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
        ),
      ],
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
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }
            final leaveList = _sortLeavesById(snapshot.data!);
            final totalItems = leaveList.length;
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex = startIndex + _itemsPerPage > totalItems
                ? totalItems
                : startIndex + _itemsPerPage;
            final paginatedLeaves = leaveList.sublist(startIndex, endIndex);

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: paginatedLeaves.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade300,
                    ),
                    itemBuilder: (context, index) {
                      final leave = paginatedLeaves[index];

                      return GestureDetector(
                        onTap: () => showLeaveDetailsDialog(context, leave),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTitleText10(text: leave.type),
                                  const SizedBox(height: 5),
                                  CustomTitleText20(
                                      text: formatDate(leave.startDate)),
                                ],
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        getStatusColor(leave.status),
                                    radius: 5,
                                  ),
                                  const SizedBox(width: 10),
                                  CustomTitleText9(text: leave.status),
                                  if (leave.status.toLowerCase() == 'approved' || leave.status.toLowerCase() == 'accepted')
                                    TextButton(
                                      onPressed: () => _showCancelConfirmation(
                                          context, leave),
                                      child: const Text("Cancel",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (totalItems > _itemsPerPage)
                  _buildPaginationControls(totalItems, _currentPage),
              ],
            );
          },
        ),
      ),
    );
  }
}
