import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presence/src/features/api/url.dart';

class ApiService {
  static final _storage = FlutterSecureStorage();

  /// User Login
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        return {
          'error': jsonDecode(response.body)['error'] ?? 'Invalid email or password'
        };
      }
    } catch (e) {
      return {'error': 'An error occurred during login: $e'};
    }
  }

  /// Forgot Password (Reset Request)
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password reset link sent to your email.'};
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseBody['error'] ?? 'Failed to send reset email.'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  /// Get Stored Access Token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'access');
  }

  /// Get Stored User Role
  static Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  /// Logout User
   Future<void> logout() async {
    print("Calling logout API...");
    try {
      String? refreshToken = await _storage.read(key: 'refresh');
      String? accessToken = await _storage.read(key: 'access');

      if (refreshToken != null && accessToken != null) {
        final response = await http.post(
          Uri.parse('$BASE_URL/logout/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'refresh': refreshToken}),
        );

        if (response.statusCode == 200) {
          print("Logout successful on backend");
        } else {
          print("Logout failed on backend: ${response.body}");
        }
      }

      await _storage.deleteAll();
      print("User logged out successfully");
    } catch (e) {
      print("Error during logout: $e");
    }
  }

   Future<void> changepassword() async {
    try {
      String? refreshToken = await _storage.read(key: 'refresh');
      String? accessToken = await _storage.read(key: 'access');

      if (refreshToken != null && accessToken != null) {
       
      }

      await _storage.deleteAll();
      print("");
    } catch (e) {
      print("");
    }
  }
  
}
