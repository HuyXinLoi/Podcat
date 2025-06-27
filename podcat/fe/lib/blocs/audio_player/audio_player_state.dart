part of 'audio_player_bloc.dart';

class AudioPlayerState extends Equatable {
  final Podcast? currentPodcast;
  final List<Podcast> playlist;
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final bool isLoading;
  final ProcessingState processingState;
  final String? error;
  final AudioServiceRepeatMode repeatMode;
  // final bool isCurrentPodcastFavorite;

  const AudioPlayerState({
    this.currentPodcast,
    this.playlist = const [],
    this.currentIndex = -1,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.isLoading = false,
    this.processingState = ProcessingState.idle,
    this.error,
    this.repeatMode = AudioServiceRepeatMode.none,
    // this.isCurrentPodcastFavorite = false,
  });

  bool get hasCurrentPodcast => currentPodcast != null;
  bool get hasNextPodcast =>
      hasCurrentPodcast && currentIndex < playlist.length - 1;
  bool get hasPreviousPodcast => hasCurrentPodcast && currentIndex > 0;

  AudioPlayerState copyWith({
    Podcast? currentPodcast,
    List<Podcast>? playlist,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? playbackSpeed,
    bool? isLoading,
    ProcessingState? processingState,
    String? error,
    bool? clearError,
    AudioServiceRepeatMode? repeatMode,
    // bool? isCurrentPodcastFavorite,
  }) {
    return AudioPlayerState(
      currentPodcast: currentPodcast ?? this.currentPodcast,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isLoading: isLoading ?? this.isLoading,
      processingState: processingState ?? this.processingState,
      error: clearError == true ? null : error ?? this.error,
      repeatMode: repeatMode ?? this.repeatMode,
      // isCurrentPodcastFavorite: isCurrentPodcastFavorite ?? this.isCurrentPodcastFavorite,
    );
  }

  @override
  List<Object?> get props => [
        currentPodcast,
        playlist,
        currentIndex,
        isPlaying,
        position,
        duration,
        playbackSpeed,
        isLoading,
        processingState,
        error,
        repeatMode,
        // isCurrentPodcastFavorite,
      ];
}
