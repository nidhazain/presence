import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/common/tokenservice.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:presence/src/features/modules/hr/hrovertime.dart';
import 'package:http/http.dart' as http;

class EmployeeOvertimeDetailPage extends StatefulWidget {
  final int employeeId;

  const EmployeeOvertimeDetailPage({Key? key, required this.employeeId})
      : super(key: key);

  @override
  _EmployeeOvertimeDetailPageState createState() =>
      _EmployeeOvertimeDetailPageState();
}

class _EmployeeOvertimeDetailPageState
    extends State<EmployeeOvertimeDetailPage> {
  bool isLoading = true;
  bool isLoadingMore = false;
  String errorMessage = '';
  late EmployeeOvertimeDetail detail;
  List<OvertimeHistoryItem> displayedHistory = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  bool hasMoreItems = true;

  @override
  void initState() {
    super.initState();
    fetchEmployeeDetail();
  }

  Future<void> fetchEmployeeDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      currentPage = 1;
      hasMoreItems = true;
    });

    try {
      await TokenService.ensureAccessToken();
      final String? token = await TokenService.getAccessToken();
      final response = await http.get(
        Uri.parse('$BASE_URL/employee/overtime/${widget.employeeId}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          detail = EmployeeOvertimeDetail.fromJson(responseData);
          displayedHistory = detail.overtimeHistory.take(itemsPerPage).toList();
          hasMoreItems = detail.overtimeHistory.length > itemsPerPage;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load details: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching details: ${e.toString()}';
      });
    }
  }

  void loadMoreItems() {
    if (isLoadingMore || !hasMoreItems) return;

    setState(() {
      isLoadingMore = true;
    });

    // Simulate network delay (remove in production)
    Future.delayed(const Duration(milliseconds: 500), () {
      final nextPageStart = currentPage * itemsPerPage;
      final nextPageEnd = nextPageStart + itemsPerPage;
      
      setState(() {
        if (nextPageStart < detail.overtimeHistory.length) {
          displayedHistory.addAll(
            detail.overtimeHistory.sublist(
              nextPageStart,
              nextPageEnd < detail.overtimeHistory.length 
                ? nextPageEnd 
                : detail.overtimeHistory.length
            )
          );
          currentPage++;
          hasMoreItems = nextPageEnd < detail.overtimeHistory.length;
        } else {
          hasMoreItems = false;
        }
        isLoadingMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: CustomTitleText(text: 'Overtime History'),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(errorMessage,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchEmployeeDetail,
                        style:
                            ElevatedButton.styleFrom(backgroundColor: primary),
                        child: const Text('Try Again',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${detail.designation} • ${detail.department}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer, color: primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Total Completed: ${detail.totalOvertime.toStringAsFixed(1)} hrs',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.history, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Overtime History',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (displayedHistory.isEmpty)
                              const Center(
                                child: Text(
                                  'No overtime history found',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  ...displayedHistory.map((item) => Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: primary.withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(Icons.date_range,
                                                    color: primary),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.date,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      item.reason,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      '${item.hours.toStringAsFixed(1)} hrs',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: primary,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: item.status
                                                                  .toLowerCase() ==
                                                              'missed'
                                                          ? red.withOpacity(0.1)
                                                          : item.status
                                                                      .toLowerCase() ==
                                                                  'completed'
                                                              ? dgreen
                                                                  .withOpacity(0.1)
                                                                  : item.status
                                                                      .toLowerCase() ==
                                                                  'upcoming'
                                                              ? Colors.blue
                                                                  .withOpacity(0.1)
                                                              : Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(50),
                                                    ),
                                                    child: Text(
                                                      item.status,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: item.status
                                                                    .toLowerCase() ==
                                                                'missed'
                                                            ? red
                                                            : item.status
                                                                        .toLowerCase() ==
                                                                    'completed'
                                                                ? dgreen
                                                                : item.status
                                                                        .toLowerCase() ==
                                                                    'upcoming'
                                                                ? Colors.blue
                                                                : primary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                  if (isLoadingMore)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  if (!isLoadingMore && hasMoreItems)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: ElevatedButton(
                                          onPressed: loadMoreItems,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            'Load More',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (!hasMoreItems && displayedHistory.isNotEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: Text(
                                          'No more items to load',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}