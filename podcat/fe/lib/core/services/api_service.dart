import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:podcat/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final http.Client _client = http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageConstants.token);
  }

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (requireAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(String endpoint,
      {bool requireAuth = true, Map<String, String>? queryParams}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);

      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client.get(uri, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, dynamic body,
      {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, dynamic body,
      {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await _client.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // dynamic _handleResponse(http.Response response) {
  //   if (response.statusCode >= 200 && response.statusCode < 300) {
  //     if (response.body.isEmpty) return null;
  //     return json.decode(response.body);
  //   } else {
  //     final errorBody =
  //         response.body.isNotEmpty ? json.decode(response.body) : {};
  //     final message = errorBody['message'] ?? 'Unknown error';

  //     switch (response.statusCode) {
  //       case 400:
  //         throw Exception('Bad request: $message');
  //       case 401:
  //         throw Exception('Unauthorized: $message');
  //       case 403:
  //         throw Exception('Forbidden: $message');
  //       case 404:
  //         throw Exception('Not found: $message');
  //       default:
  //         throw Exception('Error ${response.statusCode}: $message');
  //     }
  //   }
  // }
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.bodyBytes.isEmpty) return null;

      final decoded = utf8.decode(response.bodyBytes);
      return json.decode(decoded);
    } else {
      final decodedError = response.bodyBytes.isNotEmpty
          ? utf8.decode(response.bodyBytes)
          : '{}';
      final errorBody = json.decode(decodedError);
      final message = errorBody['message'] ?? 'Unknown error';

      switch (response.statusCode) {
        case 400:
          throw Exception('Bad request: $message');
        case 401:
          throw Exception('Unauthorized: $message');
        case 403:
          throw Exception('Forbidden: $message');
        case 404:
          throw Exception('Not found: $message');
        default:
          throw Exception('Error ${response.statusCode}: $message');
      }
    }
  }
}
