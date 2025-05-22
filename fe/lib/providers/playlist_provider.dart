import 'package:flutter/material.dart';
import '../core/services/playlist_service.dart';
import '../models/playlist.dart';

class PlaylistProvider extends ChangeNotifier {
  final PlaylistService _playlistService = PlaylistService();

  bool _isLoading = false;
  String? _error;
  List<Playlist>? _playlists;
  Playlist? _currentPlaylist;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Playlist>? get playlists => _playlists;
  Playlist? get currentPlaylist => _currentPlaylist;

  Future<void> loadPlaylists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _playlists = await _playlistService.getMyPlaylists();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPlaylist(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final playlist = await _playlistService.createPlaylist(name);
      if (_playlists != null) {
        _playlists = [playlist, ..._playlists!];
      } else {
        _playlists = [playlist];
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

  Future<bool> addPodcastToPlaylist(String playlistId, String podcastId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPlaylist =
          await _playlistService.addPodcastToPlaylist(playlistId, podcastId);

      // Update the playlist in the list
      if (_playlists != null) {
        _playlists = _playlists!.map((p) {
          if (p.id == playlistId) {
            return updatedPlaylist;
          }
          return p;
        }).toList();
      }

      // Update current playlist if it's the one being modified
      if (_currentPlaylist != null && _currentPlaylist!.id == playlistId) {
        _currentPlaylist = updatedPlaylist;
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
}
