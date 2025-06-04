import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:podcat/models/playlist.dart';
import 'package:podcat/repositories/playlist_repository.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistRepository playlistRepository;

  PlaylistBloc({required this.playlistRepository})
      : super(const PlaylistState()) {
    on<LoadPlaylists>(_onLoadPlaylists);
    on<CreatePlaylist>(_onCreatePlaylist);
    on<AddPodcastToPlaylist>(_onAddPodcastToPlaylist);
  }

  Future<void> _onLoadPlaylists(
      LoadPlaylists event, Emitter<PlaylistState> emit) async {
    emit(state.copyWith(status: PlaylistStatus.loading));
    try {
      final playlists = await playlistRepository.getMyPlaylists();
      emit(state.copyWith(
        status: PlaylistStatus.loaded,
        playlists: playlists,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PlaylistStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCreatePlaylist(
      CreatePlaylist event, Emitter<PlaylistState> emit) async {
    emit(state.copyWith(status: PlaylistStatus.loading));
    try {
      final playlist = await playlistRepository.createPlaylist(event.name);

      final updatedPlaylists = [
        playlist,
        ...state.playlists ?? [],
      ];

      emit(state.copyWith(
        status: PlaylistStatus.loaded,
        playlists: List<Playlist>.from(updatedPlaylists),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PlaylistStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAddPodcastToPlaylist(
      AddPodcastToPlaylist event, Emitter<PlaylistState> emit) async {
    emit(state.copyWith(status: PlaylistStatus.loading));
    try {
      final updatedPlaylist = await playlistRepository.addPodcastToPlaylist(
        event.playlistId,
        event.podcastId,
      );

      if (state.playlists != null) {
        final updatedPlaylists = state.playlists!.map((playlist) {
          if (playlist.id == event.playlistId) {
            return updatedPlaylist;
          }
          return playlist;
        }).toList();

        emit(state.copyWith(
          status: PlaylistStatus.loaded,
          playlists: updatedPlaylists,
          currentPlaylist: state.currentPlaylist?.id == event.playlistId
              ? updatedPlaylist
              : state.currentPlaylist,
        ));
      } else {
        emit(state.copyWith(
          status: PlaylistStatus.loaded,
          currentPlaylist: state.currentPlaylist?.id == event.playlistId
              ? updatedPlaylist
              : state.currentPlaylist,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PlaylistStatus.error,
        error: e.toString(),
      ));
    }
  }
}
