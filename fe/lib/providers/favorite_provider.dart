import 'package:flutter/material.dart';
import '../core/services/favorite_service.dart';
import '../models/page_response.dart';
import '../models/podcast.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  bool _isLoading = false;
  String? _error;
  PageResponse<Podcast>? _favorites;
  Map<String, bool> _favoriteStatus = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  PageResponse<Podcast>? get favorites => _favorites;

  bool isFavorite(String podcastId) {
    return _favoriteStatus[podcastId] ?? false;
  }

  Future<void> loadFavorites({int page = 0, int size = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await _favoriteService.getFavorites(page: page, size: size);

      // Update favorite status map
      for (var podcast in _favorites!.content) {
        _favoriteStatus[podcast.id] = true;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkFavoriteStatus(String podcastId) async {
    try {
      final isFav = await _favoriteService.isFavorite(podcastId);
      _favoriteStatus[podcastId] = isFav;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> toggleFavorite(String podcastId) async {
    try {
      await _favoriteService.toggleFavorite(podcastId);

      // Toggle local status
      _favoriteStatus[podcastId] = !(_favoriteStatus[podcastId] ?? false);

      // Update favorites list if needed
      if (_favorites != null) {
        if (_favoriteStatus[podcastId] == true) {
          // If we have the podcast details, add it to favorites
          // This would require additional logic to get the podcast details
        } else {
          // Remove from favorites
          final updatedContent =
              _favorites!.content.where((p) => p.id != podcastId).toList();
          _favorites = PageResponse<Podcast>(
            content: updatedContent,
            page: _favorites!.page,
            size: _favorites!.size,
            totalElements: _favorites!.totalElements - 1,
            totalPages: _favorites!.totalPages,
          );
        }
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }
}
