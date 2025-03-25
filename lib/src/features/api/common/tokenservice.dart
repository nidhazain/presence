import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:presence/src/features/api/url.dart';

const _storage = FlutterSecureStorage();

class TokenService {
  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access', value: access);
    await _storage.write(key: 'refresh', value: refresh);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh');
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access');
    await _storage.delete(key: 'refresh');
  }

  static Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      print('No refresh token found.');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        final newRefreshToken = data['refresh'] ?? refreshToken;
        

        await saveTokens(newAccessToken, newRefreshToken);
        print('Access token refreshed successfully.');
        return true;
      } else {
        print('Failed to refresh access token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error while refreshing token: $e');
      return false;
    }
  }

  static Future<String?> ensureAccessToken() async {
  String? accessToken = await getAccessToken();

  if (accessToken == null) {
    print('Access token is null. Attempting to refresh...');
    bool refreshed = await refreshAccessToken();
    if (refreshed) {
      accessToken = await getAccessToken();
      print('New access token obtained.');
    } else {
      print('Could not refresh access token.');
    }
  }

  return accessToken;
}

}
