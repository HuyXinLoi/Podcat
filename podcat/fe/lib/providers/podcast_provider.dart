import 'package:flutter/material.dart';
import 'package:podcat/core/services/podcast_service.dart';
import 'package:podcat/models/comment.dart';
import 'package:podcat/models/page_response.dart';
import 'package:podcat/models/podcast.dart';

class PodcastProvider extends ChangeNotifier {
  final PodcastService _podcastService = PodcastService();

  bool _isLoading = false;
  String? _error;
  PageResponse<Podcast>? _podcasts;
  Podcast? _currentPodcast;
  List<Comment>? _comments;
  PageResponse<Podcast>? _searchResults;

  bool get isLoading => _isLoading;
  String? get error => _error;
  PageResponse<Podcast>? get podcasts => _podcasts;
  Podcast? get currentPodcast => _currentPodcast;
  List<Comment>? get comments => _comments;
  PageResponse<Podcast>? get searchResults => _searchResults;

  Future<void> loadPodcasts({int page = 0, int size = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _podcasts = await _podcastService.getPodcasts(page: page, size: size);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPodcastById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPodcast = await _podcastService.getPodcastById(id);
      await loadComments(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPodcasts(String keyword,
      {int page = 0, int size = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults =
          await _podcastService.searchPodcasts(keyword, page: page, size: size);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPodcastsByCategory(String categoryId,
      {int page = 0, int size = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _podcasts = await _podcastService.getPodcastsByCategory(categoryId,
          page: page, size: size);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPodcast(Map<String, dynamic> podcastData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final podcast = await _podcastService.createPodcast(podcastData);
      if (_podcasts != null && _podcasts!.content.isNotEmpty) {
        final updatedContent = [podcast, ..._podcasts!.content];
        _podcasts = PageResponse<Podcast>(
          content: updatedContent,
          page: _podcasts!.page,
          size: _podcasts!.size,
          totalElements: _podcasts!.totalElements + 1,
          totalPages: _podcasts!.totalPages,
        );
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePodcast(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _podcastService.deletePodcast(id);
      if (_podcasts != null) {
        final updatedContent =
            _podcasts!.content.where((p) => p.id != id).toList();
        _podcasts = PageResponse<Podcast>(
          content: updatedContent,
          page: _podcasts!.page,
          size: _podcasts!.size,
          totalElements: _podcasts!.totalElements - 1,
          totalPages: _podcasts!.totalPages,
        );
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadComments(String podcastId) async {
    try {
      _comments = await _podcastService.getComments(podcastId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> addComment(String podcastId, String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final comment = await _podcastService.addComment(podcastId, content);
      if (_comments != null) {
        _comments = [comment, ..._comments!];
      } else {
        _comments = [comment];
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteComment(String podcastId, String commentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _podcastService.deleteComment(podcastId, commentId);
      if (_comments != null) {
        _comments = _comments!.where((c) => c.id != commentId).toList();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProgress(String podcastId, int progress) async {
    try {
      await _podcastService.saveProgress(podcastId, progress);
    } catch (e) {
      _error = e.toString();
    }
  }
}
