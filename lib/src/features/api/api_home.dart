// import 'dart:convert';
// import 'package:http/http.dart' as http;


// class DashboardApiService {
//   Future<DashboardData?> fetchDashboardData(String token) async {
//     final url = Uri.parse('$baseUrl/employee/dashboard/'); // Adjust the endpoint

//     final response = await http.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       return DashboardData.fromJson(json.decode(response.body));
//     } else {
//       print('Error fetching dashboard data: ${response.body}');
//       return null;
//     }
//   }
// }
