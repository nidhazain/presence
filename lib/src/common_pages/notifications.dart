import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';
import 'dart:convert';

class Notification {
  final String id;
  final String message;
  final DateTime timestamp;
  bool isRead;

  Notification({
    required this.id,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'].toString(),
      message: json['message'] ?? 'No message',
      timestamp: DateTime.parse(json['time_stamp']),
      isRead: json['is_read'] ?? false,
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Notification> _allNotifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {

await TokenService.ensureAccessToken();
      final token = TokenService.getAccessToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication required';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$BASE_URL/leavenotification/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allNotifications = data
              .map((json) => Notification.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load notifications: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching notifications: $e';
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await TokenService.ensureAccessToken();
      final token = TokenService.getAccessToken();

      final response = await http.patch(
        Uri.parse('$BASE_URL/leavenotification/$notificationId/mark_as_read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = _allNotifications.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            _allNotifications[index].isRead = true;
          }
        });
      }
    } catch (e) {
      // Handle error silently or show a snackbar
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM d, yyyy - h:mm a').format(timestamp);
  }

  List<Notification> _getTodayNotifications() {
    final now = DateTime.now();
    return _allNotifications.where((notification) {
      return notification.timestamp.day == now.day &&
          notification.timestamp.month == now.month &&
          notification.timestamp.year == now.year;
    }).toList();
  }

  List<Notification> _getYesterdayNotifications() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return _allNotifications.where((notification) {
      return notification.timestamp.day == yesterday.day &&
          notification.timestamp.month == yesterday.month &&
          notification.timestamp.year == yesterday.year;
    }).toList();
  }

  List<Notification> _getThisWeekNotifications() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final todayNotifications = _getTodayNotifications();
    final yesterdayNotifications = _getYesterdayNotifications();
    
    return _allNotifications.where((notification) {
      return notification.timestamp.isAfter(
        DateTime(weekStart.year, weekStart.month, weekStart.day),
      ) && 
      !todayNotifications.contains(notification) &&
      !yesterdayNotifications.contains(notification);
    }).toList();
  }

  List<Notification> _getOlderNotifications() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _allNotifications.where((notification) {
      return notification.timestamp.isBefore(
        DateTime(weekStart.year, weekStart.month, weekStart.day),
      );
    }).toList();
  }

  Widget _buildNotificationList(String title, List<Notification> notifications) {
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return InkWell(
              onTap: () {
                if (!notification.isRead) {
                  _markAsRead(notification.id);
                }
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: notification.isRead ? Colors.grey : Colors.black,
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayNotifications = _getTodayNotifications();
    final yesterdayNotifications = _getYesterdayNotifications();
    final thisWeekNotifications = _getThisWeekNotifications();
    final olderNotifications = _getOlderNotifications();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomTitleText(text: 'Notification'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNotificationList('Today', todayNotifications),
                        _buildNotificationList('Yesterday', yesterdayNotifications),
                        _buildNotificationList('This Week', thisWeekNotifications),
                        _buildNotificationList('Older', olderNotifications),
                      ],
                    ),
                  ),
                ),
    );
  }
}