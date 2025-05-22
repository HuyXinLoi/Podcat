import '../../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<User> getUserProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.userProfile);
      return User.fromJson(response);
    } catch (e) {
      print('Get user profile error: $e');
      throw Exception('Failed to load user profile');
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
      print('Update user profile error: $e');
      throw Exception('Failed to update user profile');
    }
  }

  Future<User> getUserById(String userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.userProfile}/$userId',
        requireAuth: false,
      );

      return User.fromJson(response);
    } catch (e) {
      print('Get user by ID error: $e');
      throw Exception('Failed to load user');
    }
  }
}
