import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presence/src/common_pages/attendance_history.dart';
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:http/http.dart' as http;
import 'package:presence/src/features/modules/employee/attendancestats.dart';

class AttendanceService {
  static final _storage = FlutterSecureStorage();

  static Future<bool> submitAttendanceRequest(Map<String, dynamic> requestData,
      {File? imageFile}) async {
    try {
      await TokenService.ensureAccessToken();
      String? token = await _storage.read(key: 'access');
      if (token == null) throw Exception('Unauthorized: No token found');

      var uri = Uri.parse('$BASE_URL/empattendance/request/');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      requestData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (imageFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      // Send the request
      var response = await request.send();

      return response.statusCode == 201;
    } catch (e) {
      print('Error submitting attendance request: $e');
      return false;
    }
  }

  Future<List<Attendance>> fetchAttendanceRecords() async {
    await TokenService.ensureAccessToken();
    final token = await TokenService.getAccessToken();

    final response = await http.get(
      Uri.parse('$BASE_URL/empattendance/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Attendance.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load attendance data');
    }
  }

  static Future<Map<String, dynamic>?> fetchEmployeeDashboard() async {
    try {
      await TokenService.ensureAccessToken();
      String? token = await TokenService.getAccessToken();
      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      final response = await http.get(
        Uri.parse('$BASE_URL/empview/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load dashboard data");
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      return null;
    }
  }

  static Future<AttendanceStats?> fetchAttendanceStats(String monthName) async {
    const List<String> months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

//   final monthIndex = months.indexOf(monthName) + 1;
  int monthNumber = months.indexOf(monthName) + 1;
  int year = DateTime.now().year;
  final token = await TokenService.getAccessToken();
  final url = Uri.parse(
      "$BASE_URL/empattendstat/?month=$monthNumber&year=$year");

  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final data = AttendanceStats.fromJson(jsonDecode(response.body));
    return data;
  } else {
    print("Failed to load data: ${response.statusCode}");
    return null;
  }
}

}
