part of 'audio_player_bloc.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayPodcast extends AudioPlayerEvent {
  final Podcast podcast;
  final List<Podcast>? playlist;
  final int? startIndex;

  const PlayPodcast({required this.podcast, this.playlist, this.startIndex});

  @override
  List<Object?> get props => [podcast, playlist, startIndex];
}

class PlayPlaylist extends AudioPlayerEvent {
  final List<Podcast> playlist;
  final int startIndex;

  const PlayPlaylist({required this.playlist, this.startIndex = 0});

  @override
  List<Object?> get props => [playlist, startIndex];
}

class NextPodcast extends AudioPlayerEvent {}

class PreviousPodcast extends AudioPlayerEvent {}

class PausePodcast extends AudioPlayerEvent {}

class ResumePodcast extends AudioPlayerEvent {}

class StopPodcast extends AudioPlayerEvent {}

class SeekTo extends AudioPlayerEvent {
  final Duration position;
  const SeekTo({required this.position});
  @override
  List<Object?> get props => [position];
}

class SetSpeed extends AudioPlayerEvent {
  final double speed;
  const SetSpeed({required this.speed});
  @override
  List<Object?> get props => [speed];
}

class UpdatePosition extends AudioPlayerEvent {
  final Duration position;
  const UpdatePosition(this.position);
  @override
  List<Object?> get props => [position];
}

class UpdateDuration extends AudioPlayerEvent {
  final Duration duration;
  const UpdateDuration(this.duration);
  @override
  List<Object?> get props => [duration];
}

class UpdatePlayerState extends AudioPlayerEvent {
  final bool isPlaying;
  final ProcessingState processingState;
  const UpdatePlayerState(
      {required this.isPlaying, required this.processingState});
  @override
  List<Object?> get props => [isPlaying, processingState];
}

class SetSleepTimer extends AudioPlayerEvent {
  final Duration duration;
  const SetSleepTimer(this.duration);

  @override
  List<Object?> get props => [duration];
}

class CancelSleepTimer extends AudioPlayerEvent {}

class SetRepeatMode extends AudioPlayerEvent {
  final AudioServiceRepeatMode mode;
  const SetRepeatMode(this.mode);

  @override
  List<Object?> get props => [mode];
}
