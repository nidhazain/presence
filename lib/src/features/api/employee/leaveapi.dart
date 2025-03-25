import 'dart:convert';
import 'dart:io';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presence/src/common_pages/leave_history.dart';
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:http/http.dart' as http;

class LeaveService {
  //static final _storage = FlutterSecureStorage();

   static Future<Map<String, dynamic>> getLeaveBalance() async {
    await TokenService.ensureAccessToken();
    final token = await TokenService.getAccessToken();
    final response = await http.get(
      Uri.parse('$BASE_URL/leavesummary/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load leave balance');
    }
  }

 static Future<Map<String, dynamic>> submitLeaveRequest({
  required String token,
  required String startDate,
  required String endDate,
  required String leaveType,
  required String reason,
  File? image,
}) async {
  final url = Uri.parse('$BASE_URL/empleave/');

  try {
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['start_date'] = startDate
      ..fields['end_date'] = endDate
      ..fields['leave_type'] = leaveType
      ..fields['reason'] = reason;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return jsonDecode(responseBody);
    } else {
      // Directly pass backend error message
      return {
        'error': jsonDecode(responseBody)['error'] ??
            'Failed to submit leave request'
      };
    }
  } catch (e) {
    return {'error': e.toString()};
  }
}


/// Fetch Leave History
static Future<List<Leave>> fetchLeaveHistory() async {
  await TokenService.ensureAccessToken();
  String? token = await TokenService.getAccessToken(); 

  if (token == null) {
    throw Exception('No access token found, user might be unauthorized.');
  }

  final response = await http.get(
    Uri.parse('$BASE_URL/empleave/'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Leave.fromJson(json)).toList();
  } else if (response.statusCode == 401) {
    throw Exception('Unauthorized: Token might be expired or invalid.');
  } else {
    throw Exception('Failed to load leave history: ${response.statusCode}');
  }
}


static Future<List<Map<String, dynamic>>> getLeaveTypes(String token) async {
  await TokenService.ensureAccessToken();
  final response = await http.get(
    Uri.parse('$BASE_URL/leave-type/'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception('Failed to load leave types');
  }
}


static Future<bool> cancelLeaveRequest(Leave leave, {required String reason}) async {
  await TokenService.ensureAccessToken();
  String? token = await TokenService.getAccessToken();
  try {
    final response = await http.put(
      Uri.parse('$BASE_URL/leave/cancel/${leave.id}/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cancellation_reason': reason,
      }),
    );
    return response.statusCode == 200;
  } catch (e) {
    print("Cancel error: $e");
    return false;
  }
}


}
