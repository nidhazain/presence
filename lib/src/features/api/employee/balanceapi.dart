import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:presence/src/features/modules/employee/balance.dart';

class BalanceService {// Replace with your backend URL

  Future<List<LeaveBalanceModel>> fetchLeaveBalance() async {
    await TokenService.ensureAccessToken();
    String? token = await TokenService.getAccessToken();
    
    final response = await http.get(
      Uri.parse('$BASE_URL/empleavebalance/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final leaveList = data['leave_balance'] as List<dynamic>;
      return leaveList.map((json) => LeaveBalanceModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load leave balances');
    }
  }
}
