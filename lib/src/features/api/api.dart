// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:presence/src/features/api/url.dart';

// class ApiService {
//   static final _storage = FlutterSecureStorage();

//  static Future<String?> refreshAccessToken() async {
  
//   try {
//     String? refreshToken = await _storage.read(key: 'refresh');
//     print("Stored refresh token: $refreshToken");

//     if (refreshToken == null) {
//       print("No refresh token found. User needs to log in again.");
//       logout();
//       return null;
//     }

//     final response = await http.post(
//       Uri.parse('$BASE_URL/token/refresh/'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'refresh': refreshToken}),
//     );

//     if (response.statusCode == 200) {
//       final responseBody = jsonDecode(response.body);
//       String newAccessToken = responseBody['access'];

//       // Store the new access token
//       await _storage.write(key: 'access', value: newAccessToken);
//       print("Access token refreshed successfully");
//       return newAccessToken;
//     } else if (response.statusCode == 401) { // Unauthorized (refresh token expired)
//       print("Refresh token expired. Logging out user...");
//       await _storage.delete(key: 'access');
//       await _storage.delete(key: 'refresh');
//       logout();
//       return null;
//     } else {
//       print("Failed to refresh token: ${response.body}");
//       return null;
//     }
//   } catch (e) {
//     print("Error refreshing token: $e");
//     return null;
//   }
// }

//   static Future<String?> _getValidAccessToken() async {
//     String? token = await _storage.read(key: 'access');
//     if (token == null) {
//       return await refreshAccessToken();
//     }
//     return token;
//   }

//   /// Submit Leave Request
//   static Future<Map<String, dynamic>> submitLeaveRequest({
//     required String token,
//     required String startDate,
//     required String endDate,
//     required String leaveType,
//     required String reason,
//   }) async {
//     final url = Uri.parse('$BASE_URL/empleave/');

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'start_date': startDate,
//           'end_date': endDate,
//           'leave_type': leaveType,
//           'reason': reason,
//         }),
//       );

//       if (response.statusCode == 201) {
//         print('Response body: ${response.body}');
//         return jsonDecode(response.body);
//       } else {
//         throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to submit leave request');
//       }
//     } catch (e) {
//       return {'error': 'An error occurred while submitting leave request: $e'};
//     }
//   }

//   /// Fetch Leave History
//   static Future<List<dynamic>> fetchLeaveHistory(String token) async {
//     final url = Uri.parse('$BASE_URL/empleave/');

//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         throw Exception('Failed to fetch leave history');
//       }
//     } catch (e) {
//       throw Exception('Error fetching leave history: $e');
//     }
//   }

//   /// User Login
//   static Future<Map<String, dynamic>?> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$BASE_URL/login/'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseBody = jsonDecode(response.body);
//         // Store Access & Refresh Tokens securely
//         // await _storage.write(key: 'access', value: responseBody['access']);
//         // await _storage.write(key: 'refresh', value: responseBody['refresh']);

//         // // Store Role securely
//         // if (responseBody.containsKey('role')) {
//         //   await _storage.write(key: 'role', value: responseBody['role']);
//         // }
//         return responseBody;
//       } else {
//         return {
//           'error': jsonDecode(response.body)['error'] ?? 'Invalid email or password'
//         };
//       }
//     } catch (e) {
//       return {'error': 'An error occurred during login: $e'};
//     }
//   }

//   /// Fetch User Profile Data
//   static Future<http.Response> fetchUserData() async {
//     try {
//       String? token = await _storage.read(key: 'access');
//       if (token == null) {
//         return http.Response('Unauthorized', 401);
//       }
//       return await http.get(
//         Uri.parse('$BASE_URL/user/profile/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token'
//         },
//       );
//     } catch (e) {
//       return http.Response('Error fetching user data: $e', 500);
//     }
//   }

//   /// Get Stored Access Token
//   static Future<String?> getToken() async {
//     return await _storage.read(key: 'access');
//   }

//   /// Get Stored User Role
//   static Future<String?> getRole() async {
//     return await _storage.read(key: 'role');
//   }

//   /// Logout User
//   static Future<void> logout() async {
//     try {
//       String? refreshToken = await _storage.read(key: 'refresh');
//       String? accessToken = await _storage.read(key: 'access');

//       if (refreshToken != null && accessToken != null) {
//         final response = await http.post(
//           Uri.parse('$BASE_URL/logout/'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $accessToken',
//           },
//           body: jsonEncode({'refresh': refreshToken}),
//         );

//         if (response.statusCode == 200) {
//           print("Logout successful on backend");
//         } else {
//           print("Logout failed on backend: ${response.body}");
//         }
//       }

//       await _storage.deleteAll();
//       print("User logged out successfully");
//     } catch (e) {
//       print("Error during logout: $e");
//     }
//   }

//   /// Fetch Attendance Data
//   static Future<Map<String, dynamic>> getAttendanceData() async {
//     try {
//       String? token = await _storage.read(key: 'access');
//       if (token == null) {
//         throw Exception('Unauthorized: No token found');
//       }

//       final response = await http.get(
//         Uri.parse('$BASE_URL/empview/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else if (response.statusCode == 401) {
//         throw Exception('Unauthorized access: Invalid or expired token');
//       } else {
//         throw Exception('Failed to load attendance data');
//       }
//     } catch (e) {
//       print('Error fetching attendance data: $e');
//       return {};
//     }
//   }

//    // Fetch Profile Data
//   static Future<Map<String, dynamic>> fetchProfileData() async {
    
//     try {
//       String? token = await _storage.read(key: 'access');
//       if (token == null) {
//         throw Exception('Unauthorized: No token found');
//       }

//       final response = await http.get(
//         Uri.parse('$BASE_URL/empprofile/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else if (response.statusCode == 401) {
//         throw Exception('Unauthorized access: Invalid or expired token');
//       } else {
//         throw Exception('Failed to fetch profile data');
//       }
//     } catch (e) {
//       print('Error fetching profile data: $e');
//       return {'error': 'Failed to fetch profile data'};
//     }
//   }

//   /// Update Profile Data (Currently Supports Updating Profile Image)
//   static Future<Map<String, dynamic>> updateProfileData({required String imagePath}) async {
    
//     try {
     
//       String? token = await _storage.read(key: 'access');
//       if (token == null) {
//         throw Exception('Unauthorized: No token found');
//       }

//       var request = http.MultipartRequest('PATCH', Uri.parse('$BASE_URL/empprofile/'))
//         ..headers['Authorization'] = 'Bearer $token';
//         if (imagePath.isNotEmpty) {
//       if (!File(imagePath).existsSync()) {
//         throw Exception('Error: File does not exist at path: $imagePath');
//       }
//       request.files.add(await http.MultipartFile.fromPath('image', imagePath));
//     }

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update profile');
//     }
//   } catch (e) {
//     print('Error updating profile: $e');
//     return {'error': e.toString()};
//   }
//   }

//   static Future<List<String>> getLeaveTypes(String token) async {
//     final response = await http.get(
//       Uri.parse('$BASE_URL/leave-types/'), // Replace with actual API URL
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> data = jsonDecode(response.body);
//       return data.map((item) => item['leave_type'].toString()).toList(); // Assuming `leave_type` is the key
//     } else {
//       throw Exception('Failed to fetch leave types');
//     }
//   }
// }


// export 'services/auth_service.dart';
// export 'services/token_service.dart';
// export 'services/leave_service.dart';
// export 'services/profile_service.dart';

export 'common/loginapi.dart';
export 'common/tokenservice.dart';
export 'employee/leaveapi.dart';
export 'employee/attendanceapi.dart';
export 'employee/profileapi.dart';