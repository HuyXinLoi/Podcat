import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:podcat/models/page_response.dart';
import 'package:podcat/models/podcast.dart';
import 'package:podcat/repositories/favorite_repository.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository favoriteRepository;

  FavoriteBloc({required this.favoriteRepository})
      : super(const FavoriteState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
      LoadFavorites event, Emitter<FavoriteState> emit) async {
    emit(state.copyWith(status: FavoriteStatus.loading));
    try {
      final favorites = await favoriteRepository.getFavorites(
        page: event.page,
        size: event.size,
      );

      final Map<String, bool> updatedStatus = Map.from(state.favoriteStatus);
      for (var podcast in favorites.content) {
        updatedStatus[podcast.id] = true;
      }

      emit(state.copyWith(
        status: FavoriteStatus.loaded,
        favorites: favorites,
        favoriteStatus: updatedStatus,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FavoriteStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCheckFavoriteStatus(
      CheckFavoriteStatus event, Emitter<FavoriteState> emit) async {
    try {
      final isFavorite = await favoriteRepository.isFavorite(event.podcastId);

      final Map<String, bool> updatedStatus = Map.from(state.favoriteStatus);
      updatedStatus[event.podcastId] = isFavorite;

      emit(state.copyWith(
        favoriteStatus: updatedStatus,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
      ));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavorite event, Emitter<FavoriteState> emit) async {
    try {
      await favoriteRepository.toggleFavorite(event.podcastId);

      final Map<String, bool> updatedStatus = Map.from(state.favoriteStatus);
      updatedStatus[event.podcastId] =
          !(updatedStatus[event.podcastId] ?? false);

      if (state.favorites != null) {
        if (updatedStatus[event.podcastId] == false) {
          final updatedContent = state.favorites!.content
              .where((podcast) => podcast.id != event.podcastId)
              .toList();

          final updatedFavorites = state.favorites!.copyWith(
            content: updatedContent,
            totalElements: state.favorites!.totalElements - 1,
          );

          emit(state.copyWith(
            favoriteStatus: updatedStatus,
            favorites: updatedFavorites,
          ));
        } else {
          emit(state.copyWith(
            favoriteStatus: updatedStatus,
          ));
        }
      } else {
        emit(state.copyWith(
          favoriteStatus: updatedStatus,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
      ));
    }
  }
}
