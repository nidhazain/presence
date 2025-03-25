import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';


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
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Dummy data
  final List<Notification> _allNotifications = [
    Notification(
      id: '1',
      message: 'John Doe has requested leave from April 10-15, 2025.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Notification(
      id: '2',
      message: 'Sarah Williams will be 30 minutes late today due to traffic.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Notification(
      id: '3',
      message: 'Remote work policy has been updated. Please review the changes.',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Notification(
      id: '4',
      message: 'Your leave request for March 26-28 has been approved.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Notification(
      id: '5',
      message: 'Michael Brown\'s leave request has been rejected due to staff shortage.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Notification(
      id: '6',
      message: 'Robert Johnson will be late by 45 minutes due to a doctor\'s appointment.',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Notification(
      id: '7',
      message: 'New dress code policy has been implemented effective April 1, 2025.',
      timestamp: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

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
            return Card(
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
  centerTitle: true, // This centers the title
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

      body: SingleChildScrollView(
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
    );
  }
}