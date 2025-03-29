 import 'package:presence/src/features/api/url.dart';

class ApiEndpoints {
 String pendingLeaveRequests = '$BASE_URL/hrleaverequestview/';
 String approveRejectLeave = '$BASE_URL/approve-reject-leave/';
 String pendingCancellationRequests = '$BASE_URL/leavecancellationview/';
 String approveRejectCancellation = '$BASE_URL/approve-reject-cancellation/';
}