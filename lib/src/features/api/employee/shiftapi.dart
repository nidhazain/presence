import 'dart:convert';
import 'package:http/http.dart' as http;
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
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
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
}
