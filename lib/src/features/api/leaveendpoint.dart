 import 'package:presence/src/features/api/url.dart';

class ApiEndpoints {
  final String pendingLeaveRequests = '$BASE_URL/hrleaverequestview/';
  final String approveRejectLeave = '$BASE_URL/approve-reject-leave/';
  
  // If you need to make them static, you would declare them like this:
  // static const String pendingLeaveRequests = 'your-api-url/pending-leaves/';
  // static const String approveRejectLeave = 'your-api-url/leaves/';
}