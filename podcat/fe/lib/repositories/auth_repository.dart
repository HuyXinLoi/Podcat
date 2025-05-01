import 'package:podcat/core/services/api_service.dart';
import 'package:podcat/core/utils/constants.dart';
import 'package:podcat/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageConstants.token) != null;
  }

  Future<String?> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        {'username': username, 'password': password},
        requireAuth: false,
      );

      if (response != null && response['token'] != null) {
        await _saveToken(response['token']);
        return response['token'];
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<String?> register(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        {'username': username, 'password': password},
        requireAuth: false,
      );

      if (response != null && response['token'] != null) {
        await _saveToken(response['token']);
        return response['token'];
      }
      return null;
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageConstants.token);
    await prefs.remove(StorageConstants.userId);
    await prefs.remove(StorageConstants.username);
  }

  Future<User> getUserProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.userProfile);
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  Future<User> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.put(
        ApiConstants.userProfile,
        profileData,
      );
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageConstants.token, token);
  }
}
