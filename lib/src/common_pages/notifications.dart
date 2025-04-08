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
    required this.isRead,
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
  
  // Pagination parameters
  final int _itemsPerPage = 5; // Load 5 items initially
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });
    
    try {
      await TokenService.ensureAccessToken();
      String? token = await TokenService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$BASE_URL/leavenotification/?page=$_currentPage&page_size=$_itemsPerPage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if the response is paginated
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          // Handle paginated response
          final List<dynamic> results = data['results'];
          final bool hasNext = data['next'] != null;
          
          setState(() {
            _allNotifications = results
                .map((json) => Notification.fromJson(json))
                .toList();
            _hasMorePages = hasNext;
            _isLoading = false;
          });
        } else {
          // Handle non-paginated response (for backward compatibility)
          final List<dynamic> notifications = data is List ? data : [];
          
          // If not paginated, just take the first 5 items
          final limitedNotifications = notifications.take(_itemsPerPage).toList();
          
          setState(() {
            _allNotifications = limitedNotifications
                .map((json) => Notification.fromJson(json))
                .toList();
            _hasMorePages = notifications.length > _itemsPerPage;
            _isLoading = false;
          });
        }
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

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMorePages) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      await TokenService.ensureAccessToken();
      String? token = await TokenService.getAccessToken();
      
      final nextPage = _currentPage + 1;
      final response = await http.get(
        Uri.parse('$BASE_URL/leavenotification/?page=$nextPage&page_size=$_itemsPerPage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          final List<dynamic> results = data['results'];
          final bool hasNext = data['next'] != null;
          
          if (results.isNotEmpty) {
            final newNotifications = results
                .map((json) => Notification.fromJson(json))
                .toList();
                
            setState(() {
              _allNotifications.addAll(newNotifications);
              _currentPage = nextPage;
              _hasMorePages = hasNext;
              _isLoadingMore = false;
            });
          } else {
            setState(() {
              _hasMorePages = false;
              _isLoadingMore = false;
            });
          }
        } else {
          // Handle non-paginated response
          final List<dynamic> allNotifications = data is List ? data : [];
          final int startIndex = _currentPage * _itemsPerPage;
          
          if (startIndex < allNotifications.length) {
            final int endIndex = (startIndex + _itemsPerPage > allNotifications.length) 
                ? allNotifications.length 
                : startIndex + _itemsPerPage;
            
            final newNotifications = allNotifications.sublist(startIndex, endIndex)
                .map((json) => Notification.fromJson(json))
                .toList();
            
            setState(() {
              _allNotifications.addAll(newNotifications);
              _currentPage = nextPage;
              _hasMorePages = endIndex < allNotifications.length;
              _isLoadingMore = false;
            });
          } else {
            setState(() {
              _hasMorePages = false;
              _isLoadingMore = false;
            });
          }
        }
      } else {
        setState(() {
          _isLoadingMore = false;
          _errorMessage = 'Failed to load more notifications: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _errorMessage = 'Error loading more notifications: $e';
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await TokenService.ensureAccessToken();
      final token = await TokenService.getAccessToken();
      final response = await http.patch(
        Uri.parse('$BASE_URL/notifications/$notificationId/mark_as_read/'),
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
      print('Error marking notification as read: $e');
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

  Widget _buildLoadMoreButton() {
    if (!_hasMorePages) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: _isLoadingMore 
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _loadMoreNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Load More'),
              ),
      ),
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
        title: CustomTitleText(text: 'Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNotificationList('Today', todayNotifications),
                            _buildNotificationList('Yesterday', yesterdayNotifications),
                            _buildNotificationList('This Week', thisWeekNotifications),
                            _buildNotificationList('Older', olderNotifications),
                            
                            // Load more button
                            _buildLoadMoreButton(),
                            
                            // Space at the bottom to allow pull to refresh when list is short
                            if (_allNotifications.isEmpty)
                              const SizedBox(height: 100),
                          ],
                        ),
                      ),
                      
                      // Empty state view
                      if (_allNotifications.isEmpty && !_isLoading)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No notifications yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
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