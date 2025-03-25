import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';

class HrDashboardService {

  static Future<Map<String, dynamic>> fetchDashboardData() async {
    await TokenService.ensureAccessToken();
    String? token = await TokenService.getAccessToken();
    final response = await http.get(
      Uri.parse('$BASE_URL/hrdashboard/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse the JSON response into a Map
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }
}
