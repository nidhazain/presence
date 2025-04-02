import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';

class ShiftService {
  static Future<List<dynamic>> fetchShiftData() async {
    await TokenService.ensureAccessToken();
    String? token = await TokenService.getAccessToken();
    final response = await http.get(
      Uri.parse('$BASE_URL/employeedashboardshifts/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load shift data');
    }
  }

  static Future<List<String>> fetchShiftColleagues() async {
    await TokenService.ensureAccessToken();
    String? token = await TokenService.getAccessToken();
    final response = await http.get(
      Uri.parse('$BASE_URL/shift/colleagues/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      // Assuming each item contains an "employee_name" field.
      return data
          .map<String>((item) => item['employee_name']?.toString() ?? '')
          .toList();
    } else {
      throw Exception('Failed to load shift colleagues');
    }
  }

  static Future<Map<String, dynamic>> fetchShiftAssignments() async {
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final url = Uri.parse('$BASE_URL/assignview/?date=$currentDate');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load shift assignments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load shift assignments: $e');
    }
  }
}

