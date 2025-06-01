part of 'audio_player_bloc.dart';

class AudioPlayerState extends Equatable {
  final Podcast? currentPodcast;
  final List<Podcast> playlist;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final ProcessingState processingState;
  final String? error;

  const AudioPlayerState({
    this.currentPodcast,
    this.playlist = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.processingState = ProcessingState.idle,
    this.error,
  });

  AudioPlayerState copyWith({
    Podcast? currentPodcast,
    List<Podcast>? playlist,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? playbackSpeed,
    ProcessingState? processingState,
    String? error,
  }) {
    return AudioPlayerState(
      currentPodcast: currentPodcast ?? this.currentPodcast,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      processingState: processingState ?? this.processingState,
      error: error,
    );
  }

  bool get hasCurrentPodcast => currentPodcast != null;
  bool get hasNextPodcast =>
      playlist.isNotEmpty && currentIndex < playlist.length - 1;
  bool get hasPreviousPodcast => playlist.isNotEmpty && currentIndex > 0;

  @override
  List<Object?> get props => [
        currentPodcast,
        playlist,
        currentIndex,
        isPlaying,
        isLoading,
        position,
        duration,
        playbackSpeed,
        processingState,
        error,
      ];
}
