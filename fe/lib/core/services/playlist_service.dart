import '../../models/playlist.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class PlaylistService {
  final ApiService _apiService = ApiService();

  Future<List<Playlist>> getMyPlaylists() async {
    try {
      final response = await _apiService.get(ApiConstants.myPlaylists);

      return (response as List).map((json) => Playlist.fromJson(json)).toList();
    } catch (e) {
      print('Get my playlists error: $e');
      throw Exception('Failed to load playlists');
    }
  }

  Future<Playlist> createPlaylist(String name) async {
    try {
      final response = await _apiService.post(
        ApiConstants.playlists,
        {'name': name},
      );

      return Playlist.fromJson(response);
    } catch (e) {
      print('Create playlist error: $e');
      throw Exception('Failed to create playlist');
    }
  }

  Future<Playlist> addPodcastToPlaylist(
      String playlistId, String podcastId) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.playlists}/$playlistId/add',
        {'podcastId': podcastId},
      );

      return Playlist.fromJson(response);
    } catch (e) {
      print('Add podcast to playlist error: $e');
      throw Exception('Failed to add podcast to playlist');
    }
  }
}
