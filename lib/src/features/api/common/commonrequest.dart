import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<dynamic> commonRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    File? image,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      if (method == 'POST' && image != null) {
        var request = http.MultipartRequest('POST', Uri.parse(url))
          ..fields.addAll(body!.map((key, value) => MapEntry(key, value.toString())))
          ..files.add(await http.MultipartFile.fromPath('image', image.path));
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        return jsonDecode(response.body);
      } else {
        late http.Response response;

        if (method == 'GET') {
          response = await http.get(Uri.parse(url), headers: headers);
        } else if (method == 'POST') {
          response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
        } else if (method == 'PUT') {
          response = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
        } else if (method == 'DELETE') {
          response = await http.delete(Uri.parse(url), headers: headers);
        } else {
          throw Exception('Invalid HTTP method');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(response.body);
        } else {
          return {
            'status': response.statusCode,
            'message': jsonDecode(response.body)['message'] ?? 'Something went wrong',
          };
        }
      }
    } catch (e) {
      return {
        'status': 500,
        'message': 'Something went wrong: $e',
      };
    }
  }
}

// Explanation:
// 1. We set headers, and if needed, can integrate tokens later.
// 2. If image upload is needed, we use MultipartRequest.
// 3. Otherwise, use proper HTTP requests with JSON body.
// 4. We handle all methods — GET, POST, PUT, DELETE.
// 5. Successful response is parsed and returned, errors are caught and formatted.
// 6. This matches your common request style with added image support!
