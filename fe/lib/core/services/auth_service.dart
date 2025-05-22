import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        {'username': username, 'password': password},
        requireAuth: false,
      );

      if (response != null && response['token'] != null) {
        await _saveToken(response['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        {'username': username, 'password': password},
        requireAuth: false,
      );

      if (response != null && response['token'] != null) {
        await _saveToken(response['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageConstants.token);
    await prefs.remove(StorageConstants.userId);
    await prefs.remove(StorageConstants.username);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageConstants.token) != null;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageConstants.token, token);
  }
}
