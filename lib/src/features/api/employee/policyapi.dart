import 'dart:convert';
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:http/http.dart' as http;
import 'package:presence/src/features/modules/employee/policy.dart';

class PolicyService {

  static Future<PolicyResponse> fetchPolicyData() async {
    await TokenService.ensureAccessToken();
    final token = await TokenService.getAccessToken();
  final response = await http.get(
    Uri.parse('$BASE_URL/policy-view/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return PolicyResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load policy data');
  }
}

static Future<List<dynamic>> fetchPublicHolidays() async {
  await TokenService.ensureAccessToken();
  final token = await TokenService.getAccessToken();
  final response = await http.get(
    Uri.parse('$BASE_URL/policy-view/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['public_holidays']; 
  } else {
    throw Exception('Failed to load policy data');
  }
}
}