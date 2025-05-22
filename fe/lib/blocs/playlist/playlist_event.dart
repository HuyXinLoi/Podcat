part of 'playlist_bloc.dart';

abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object> get props => [];
}

class LoadPlaylists extends PlaylistEvent {}

class CreatePlaylist extends PlaylistEvent {
  final String name;

  const CreatePlaylist({required this.name});

  @override
  List<Object> get props => [name];
}

class AddPodcastToPlaylist extends PlaylistEvent {
  final String playlistId;
  final String podcastId;

  const AddPodcastToPlaylist({
    required this.playlistId,
    required this.podcastId,
  });

  @override
  List<Object> get props => [playlistId, podcastId];
}
