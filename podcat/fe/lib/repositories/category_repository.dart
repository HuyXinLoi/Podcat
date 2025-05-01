import 'package:podcat/core/services/api_service.dart';
import 'package:podcat/core/utils/constants.dart';
import 'package:podcat/models/category.dart';

class CategoryRepository {
  final ApiService _apiService = ApiService();

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get(
        ApiConstants.categories,
        requireAuth: false,
      );

      return (response as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<Category> getCategoryById(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.categories}/$id',
        requireAuth: false,
      );

      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }

  Future<List<Category>> searchCategories(String keyword) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.categories}/search',
        requireAuth: false,
        queryParams: {'keyword': keyword},
      );

      return (response as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search categories: $e');
    }
  }
}
