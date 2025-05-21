import 'package:podcat/core/services/api_service.dart';
import 'package:podcat/core/utils/constants.dart';
import 'package:podcat/models/comment.dart';
import 'package:podcat/models/page_response.dart';
import 'package:podcat/models/podcast.dart';

class PodcastService {
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
      print('Get podcasts error: $e');
      throw Exception('Failed to load podcasts');
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
      print('Get podcast by ID error: $e');
      throw Exception('Failed to load podcast');
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
      print('Search podcasts error: $e');
      throw Exception('Failed to search podcasts');
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
      print('Get podcasts by category error: $e');
      throw Exception('Failed to load podcasts by category');
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
      print('Create podcast error: $e');
      throw Exception('Failed to create podcast');
    }
  }

  Future<void> deletePodcast(String id) async {
    try {
      await _apiService.delete('${ApiConstants.podcasts}/$id');
    } catch (e) {
      print('Delete podcast error: $e');
      throw Exception('Failed to delete podcast');
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
      print('Get comments error: $e');
      throw Exception('Failed to load comments');
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
      print('Add comment error: $e');
      throw Exception('Failed to add comment');
    }
  }

  Future<void> deleteComment(String podcastId, String commentId) async {
    try {
      await _apiService.delete(
        '${ApiConstants.podcasts}/$podcastId/comments/$commentId',
      );
    } catch (e) {
      print('Delete comment error: $e');
      throw Exception('Failed to delete comment');
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
      print('Save progress error: $e');
      throw Exception('Failed to save progress');
    }
  }
}
