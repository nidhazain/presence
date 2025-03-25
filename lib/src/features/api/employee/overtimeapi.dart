import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:presence/src/common_pages/overtime_history.dart';
import 'package:presence/src/features/api/common/tokenservice.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:presence/src/features/modules/employee/overtime_stats.dart';

class OvertimeService {
  static Future<OvertimeStats> fetchOvertimeStats() async {
    await TokenService.ensureAccessToken();
  final token = await TokenService.getAccessToken();
  final response = await http.get(
    Uri.parse('$BASE_URL/empovertime/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return OvertimeStats.fromJson(jsonData);
  } else {
    print("Error fetching overtime stats: ${response.body}");
    throw Exception('Failed to load overtime stats');
  }
}


  static Future<Map<String, List<OvertimeEntry>>>
      getOvertimeAssignments() async {
        await TokenService.ensureAccessToken();
    final token = await TokenService.getAccessToken();
    final response = await http.get(
      Uri.parse('$BASE_URL/empoverstat/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final upcoming = (jsonData['upcoming_overtime'] as List)
          .map((e) => OvertimeEntry(
              date: DateTime.parse(e['date']),
              hours: e['hours'],
              status: e['status'],
              reason: e['reason']))
          .toList();

      final missed = (jsonData['missed_overtime'] as List)
          .map((e) => OvertimeEntry(
              date: DateTime.parse(e['date']),
              hours: e['hours'],
              status: e['status'],
              reason: e['reason']))
          .toList();

          final completed = (jsonData['completed_overtime'] as List)
          .map((e) => OvertimeEntry(
              date: DateTime.parse(e['date']),
              hours: e['hours'],
              status: e['status'],
              reason: e['reason']))
          .toList();

      return {
        'upcoming_overtime': upcoming,
        'missed_overtime': missed,
        'completed_overtime': completed,
      };
    } else {
      throw Exception('Failed to load overtime assignments');
    }
  }
} 
