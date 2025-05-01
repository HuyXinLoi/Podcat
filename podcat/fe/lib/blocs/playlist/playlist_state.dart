part of 'playlist_bloc.dart';

enum PlaylistStatus { initial, loading, loaded, error }

class PlaylistState extends Equatable {
  final PlaylistStatus status;
  final List<Playlist>? playlists;
  final Playlist? currentPlaylist;
  final String? error;

  const PlaylistState({
    this.status = PlaylistStatus.initial,
    this.playlists,
    this.currentPlaylist,
    this.error,
  });

  PlaylistState copyWith({
    PlaylistStatus? status,
    List<Playlist>? playlists,
    Playlist? currentPlaylist,
    String? error,
  }) {
    return PlaylistState(
      status: status ?? this.status,
      playlists: playlists ?? this.playlists,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, playlists, currentPlaylist, error];
}
