import 'dart:convert';
import 'package:presence/src/features/api/common/tokenservice.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:http/http.dart' as http;
//import 'package:presence/src/features/modules/employee/home.dart';
import 'package:presence/src/models/empdashboard.dart';

class DashboardService {
  static Future<DashboardData> fetchDashboardData() async {
    print('api called');
    await TokenService.ensureAccessToken();
    final token = await TokenService.getAccessToken();
    final response = await http.get(
      Uri.parse('$BASE_URL/empview/'), 
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ); 
    print('api called ${response.body}');
    if (response.statusCode == 200) {
      return DashboardData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }
}

