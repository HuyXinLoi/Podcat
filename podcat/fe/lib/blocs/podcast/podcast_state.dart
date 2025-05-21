part of 'podcast_bloc.dart';

enum PodcastStatus { initial, loading, loaded, error }

class PodcastState extends Equatable {
  final PodcastStatus status;
  final PageResponse<Podcast>? podcasts;
  final Podcast? currentPodcast;
  final List<Comment>? comments;
  final PageResponse<Podcast>? searchResults;
  final String? error;

  const PodcastState({
    this.status = PodcastStatus.initial,
    this.podcasts,
    this.currentPodcast,
    this.comments,
    this.searchResults,
    this.error,
  });

  PodcastState copyWith({
    PodcastStatus? status,
    PageResponse<Podcast>? podcasts,
    Podcast? currentPodcast,
    List<Comment>? comments,
    PageResponse<Podcast>? searchResults,
    String? error,
  }) {
    return PodcastState(
      status: status ?? this.status,
      podcasts: podcasts ?? this.podcasts,
      currentPodcast: currentPodcast ?? this.currentPodcast,
      comments: comments ?? this.comments,
      searchResults: searchResults ?? this.searchResults,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        podcasts,
        currentPodcast,
        comments,
        searchResults,
        error,
      ];
}
