import 'package:podcat/core/services/api_service.dart';
import 'package:podcat/core/utils/constants.dart';
import 'package:podcat/models/page_response.dart';
import 'package:podcat/models/podcast.dart';

class FavoriteRepository {
  final ApiService _apiService = ApiService();

  Future<void> toggleFavorite(String podcastId) async {
    try {
      await _apiService.post(
        '${ApiConstants.favorites}/$podcastId',
        {},
      );
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  Future<bool> isFavorite(String podcastId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.favorites}/$podcastId',
      );

      return response as bool;
    } catch (e) {
      return false;
    }
  }

  Future<PageResponse<Podcast>> getFavorites(
      {int page = 0, int size = 20}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.favorites,
        queryParams: {
          'page': page.toString(),
          'size': size.toString(),
        },
      );

      return PageResponse<Podcast>.fromJson(
        response,
        (json) => Podcast.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }
}
