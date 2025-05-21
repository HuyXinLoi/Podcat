import 'package:podcat/core/services/api_service.dart';
import 'package:podcat/core/utils/constants.dart';
import 'package:podcat/models/comment.dart';
import 'package:podcat/models/page_response.dart';
import 'package:podcat/models/podcast.dart';

class PodcastRepository {
  final ApiService _apiService = ApiService();

  Future<PageResponse<Podcast>> getPodcasts(
      {int page = 0, int size = 20}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.podcasts,
        requireAuth: false,
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
      throw Exception('Failed to load podcasts: $e');
    }
  }

  Future<Podcast> getPodcastById(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.podcasts}/$id',
        requireAuth: false,
      );

      return Podcast.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load podcast: $e');
    }
  }

  Future<PageResponse<Podcast>> searchPodcasts(String keyword,
      {int page = 0, int size = 20}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.search,
        requireAuth: false,
        queryParams: {
          'keyword': keyword,
          'page': page.toString(),
          'size': size.toString(),
        },
      );

      return PageResponse<Podcast>.fromJson(
        response,
        (json) => Podcast.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to search podcasts: $e');
    }
  }

  Future<PageResponse<Podcast>> getPodcastsByCategory(String categoryId,
      {int page = 0, int size = 20}) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.podcastsByCategory}/$categoryId',
        requireAuth: false,
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
      throw Exception('Failed to load podcasts by category: $e');
    }
  }

  Future<Podcast> createPodcast(Map<String, dynamic> podcastData) async {
    try {
      final response = await _apiService.post(
        ApiConstants.podcasts,
        podcastData,
      );

      return Podcast.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create podcast: $e');
    }
  }

  Future<void> deletePodcast(String id) async {
    try {
      await _apiService.delete('${ApiConstants.podcasts}/$id');
    } catch (e) {
      throw Exception('Failed to delete podcast: $e');
    }
  }

  Future<List<Comment>> getComments(String podcastId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.podcasts}/$podcastId/comments',
        requireAuth: false,
      );

      return (response as List).map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  Future<Comment> addComment(String podcastId, String content) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.podcasts}/$podcastId/comments',
        {'content': content},
      );

      return Comment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> deleteComment(String podcastId, String commentId) async {
    try {
      await _apiService.delete(
        '${ApiConstants.podcasts}/$podcastId/comments/$commentId',
      );
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<void> saveProgress(String podcastId, int progress) async {
    try {
      await _apiService.post(
        ApiConstants.history,
        {
          'podcastId': podcastId,
          'progress': progress,
        },
      );
    } catch (e) {
      throw Exception('Failed to save progress: $e');
    }
  }
}
