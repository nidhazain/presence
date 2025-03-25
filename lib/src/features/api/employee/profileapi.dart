import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presence/src/features/api/api.dart';
// import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  static final _storage = FlutterSecureStorage();

  // Fetch Profile Data
  static Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      await TokenService.ensureAccessToken();
      String? token = await TokenService.getAccessToken();

      if (token == null) {
        throw Exception('Unauthorized: No token found');
      }

      final response = await http.get(
        Uri.parse('$BASE_URL/empprofile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            'Profile API Error: Status ${response.statusCode} - ${response.body}');
        if (response.statusCode == 401) {
          throw Exception('Unauthorized access: Invalid or expired token');
        } else {
          throw Exception('Failed to fetch profile data');
        }
      }
    } on SocketException catch (_) {
      throw Exception('Network error: Please check your internet connection.');
    } catch (e) {
      // Log the error if needed
      throw Exception('Failed to fetch profile data: $e');
    }
  }

  /// Update Profile Data (Currently Supports Updating Profile Image)
  static Future<Map<String, dynamic>> updateProfileData(
      {required String imagePath}) async {
    try {
      await TokenService.ensureAccessToken();
      String? token = await _storage.read(key: 'access');
      if (token == null) {
        throw Exception('Unauthorized: No token found');
      }

      var request =
          http.MultipartRequest('PATCH', Uri.parse('$BASE_URL/empprofile/'))
            ..headers['Authorization'] = 'Bearer $token';
      if (imagePath.isNotEmpty) {
        if (!File(imagePath).existsSync()) {
          throw Exception('Error: File does not exist at path: $imagePath');
        }
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            jsonDecode(response.body)['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error updating profile: $e');
      return {'error': e.toString()};
    }
  }
}
