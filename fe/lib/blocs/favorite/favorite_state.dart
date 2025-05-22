part of 'favorite_bloc.dart';

enum FavoriteStatus { initial, loading, loaded, error }

class FavoriteState extends Equatable {
  final FavoriteStatus status;
  final PageResponse<Podcast>? favorites;
  final Map<String, bool> favoriteStatus;
  final String? error;

  const FavoriteState({
    this.status = FavoriteStatus.initial,
    this.favorites,
    this.favoriteStatus = const {},
    this.error,
  });

  FavoriteState copyWith({
    FavoriteStatus? status,
    PageResponse<Podcast>? favorites,
    Map<String, bool>? favoriteStatus,
    String? error,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
      error: error,
    );
  }

  bool isFavorite(String podcastId) {
    return favoriteStatus[podcastId] ?? false;
  }

  @override
  List<Object?> get props => [status, favorites, favoriteStatus, error];
}
