import '../../models/category.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get(
        ApiConstants.categories,
        requireAuth: false,
      );

      return (response as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print('Get categories error: $e');
      throw Exception('Failed to load categories');
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
      print('Get category by ID error: $e');
      throw Exception('Failed to load category');
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
      print('Search categories error: $e');
      throw Exception('Failed to search categories');
    }
  }
}
