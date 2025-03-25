import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/features/api/employee/overtimeapi.dart';

import '../constants/colors.dart';

class OvertimeHistoryPage extends StatefulWidget {
  const OvertimeHistoryPage({super.key});
  
  @override
  State<OvertimeHistoryPage> createState() => _OvertimeHistoryPageState();
}

class _OvertimeHistoryPageState extends State<OvertimeHistoryPage> with SingleTickerProviderStateMixin {
  List<OvertimeEntry> upcoming = [];
  List<OvertimeEntry> missed = [];
  List<OvertimeEntry> completed = [];
  bool isLoading = true;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchOvertimeData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchOvertimeData() async {
    try {
      final assignments = await OvertimeService.getOvertimeAssignments();
      
      setState(() {
        upcoming = assignments['upcoming_overtime']!;
        missed = assignments['missed_overtime']!;
        completed = assignments['completed_overtime']!;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching overtime assignments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Overtime History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(
              text: "Upcoming",
              //icon: Icon(Icons.schedule),
            ),
            Tab(
              text: "Completed",
              //icon: Icon(Icons.check_circle_outline),
            ),
            Tab(
              text: "Missed",
              //icon: Icon(Icons.cancel_outlined),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchOvertimeData,
              color: Theme.of(context).primaryColor,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent(upcoming, screenHeight, "upcoming"),
                  _buildTabContent(completed, screenHeight, "completed"),
                  _buildTabContent(missed, screenHeight, "missed"),
                ],
              ),
            ),
    );
  }

  Widget _buildTabContent(List<OvertimeEntry> entries, double screenHeight, String type) {
    return entries.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyStateIcon(type),
                  size: 70,
                  color: Colors.grey.withOpacity(0.7),
                ),
                SizedBox(height: 16),
                Text(
                  _getEmptyStateMessage(type),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) => _buildOvertimeCard(entries[index], screenHeight, type),
          );
  }

  IconData _getEmptyStateIcon(String type) {
    switch (type) {
      case "upcoming":
        return Icons.event_available;
      case "completed":
        return Icons.check_circle;
      case "missed":
        return Icons.event_busy;
      default:
        return Icons.event_note;
    }
  }

  String _getEmptyStateMessage(String type) {
    switch (type) {
      case "upcoming":
        return "No upcoming overtime scheduled";
      case "completed":
        return "No completed overtime";
      case "missed":
        return "No missed overtime";
      default:
        return "No records available";
    }
  }

  Widget _buildOvertimeCard(OvertimeEntry entry, double screenHeight, String type) {
    Color statusColor;
    IconData statusIcon;
    
    switch (type) {
      case "upcoming":
        statusColor = const Color.fromARGB(255, 106, 175, 249);
        statusIcon = Icons.schedule;
        break;
      case "completed":
        statusColor = dgreen;
        statusIcon = Icons.check_circle;
        break;
      case "missed":
        statusColor = red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    String dayName = DateFormat('EEEE').format(entry.date);
    String formattedDate = DateFormat("dd MMM yyyy").format(entry.date);
    
    return Container(
      
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show details dialog or navigate to detail page
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor),
                      SizedBox(width: 8),
                      Text(
                        dayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${entry.hours} hrs",
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.date_range, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.subject, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.reason ?? "No reason provided",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OvertimeEntry {
  final DateTime date;
  final int hours;
  final String? reason;  // Made nullable
  final String? status;  // Made nullable and stored as property

  OvertimeEntry({
    required this.date, 
    required this.hours, 
    this.status,  // Optional parameter
    this.reason,  // Optional parameter
  });

  factory OvertimeEntry.fromJson(Map<String, dynamic> json) {
    return OvertimeEntry(
      date: DateTime.parse(json['date']),
      hours: json['hours'] ?? 0,  // Provide default if null
      reason: json['reason'] as String?,  // Cast as nullable String
      status: json['status'] as String?,  // Cast as nullable String
    );
  }
}