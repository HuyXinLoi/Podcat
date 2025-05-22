part of 'favorite_bloc.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoriteEvent {
  final int page;
  final int size;

  const LoadFavorites({this.page = 0, this.size = 20});

  @override
  List<Object> get props => [page, size];
}

class CheckFavoriteStatus extends FavoriteEvent {
  final String podcastId;

  const CheckFavoriteStatus({required this.podcastId});

  @override
  List<Object> get props => [podcastId];
}

class ToggleFavorite extends FavoriteEvent {
  final String podcastId;

  const ToggleFavorite({required this.podcastId});

  @override
  List<Object> get props => [podcastId];
}
