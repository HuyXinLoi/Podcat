import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:podcat/models/podcast.dart';

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerBloc() : super(const AudioPlayerState()) {
    on<PlayPodcast>(_onPlayPodcast);
    on<PlayPlaylist>(_onPlayPlaylist);
    on<NextPodcast>(_onNextPodcast);
    on<PreviousPodcast>(_onPreviousPodcast);
    on<PausePodcast>(_onPausePodcast);
    on<ResumePodcast>(_onResumePodcast);
    on<StopPodcast>(_onStopPodcast);
    on<SeekTo>(_onSeekTo);
    on<SetSpeed>(_onSetSpeed);
    on<UpdatePosition>(_onUpdatePosition);
    on<UpdateDuration>(_onUpdateDuration);
    on<UpdatePlayerState>(_onUpdatePlayerState);

    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      add(UpdatePlayerState(
        isPlaying: playerState.playing,
        processingState: playerState.processingState,
      ));
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      add(UpdatePosition(position));
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        add(UpdateDuration(duration));
      }
    });

    // Auto play next when current song ends
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (state.hasNextPodcast) {
          add(NextPodcast());
        }
      }
    });
  }

  Future<void> _onPlayPodcast(
      PlayPodcast event, Emitter<AudioPlayerState> emit) async {
    try {
      List<Podcast> playlist = event.playlist ?? [event.podcast];
      int currentIndex = event.startIndex ??
          playlist.indexWhere((p) => p.id == event.podcast.id);

      if (currentIndex == -1) {
        currentIndex = 0;
        playlist = [event.podcast, ...playlist];
      }

      emit(state.copyWith(
        currentPodcast: event.podcast,
        playlist: playlist,
        currentIndex: currentIndex,
        isLoading: true,
        position: Duration.zero,
        playbackSpeed: 1.0,
      ));

      await _playCurrentPodcast(event.podcast);

      emit(state.copyWith(
        isLoading: false,
        isPlaying: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onPlayPlaylist(
      PlayPlaylist event, Emitter<AudioPlayerState> emit) async {
    if (event.playlist.isEmpty) return;

    final podcast = event.playlist[event.startIndex];
    add(PlayPodcast(
      podcast: podcast,
      playlist: event.playlist,
      startIndex: event.startIndex,
    ));
  }

  Future<void> _onNextPodcast(
      NextPodcast event, Emitter<AudioPlayerState> emit) async {
    if (!state.hasNextPodcast) return;

    final nextIndex = state.currentIndex + 1;
    final nextPodcast = state.playlist[nextIndex];

    try {
      emit(state.copyWith(
        currentPodcast: nextPodcast,
        currentIndex: nextIndex,
        isLoading: true,
        position: Duration.zero,
      ));

      await _playCurrentPodcast(nextPodcast);

      emit(state.copyWith(
        isLoading: false,
        isPlaying: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onPreviousPodcast(
      PreviousPodcast event, Emitter<AudioPlayerState> emit) async {
    if (!state.hasPreviousPodcast) return;

    final previousIndex = state.currentIndex - 1;
    final previousPodcast = state.playlist[previousIndex];

    try {
      emit(state.copyWith(
        currentPodcast: previousPodcast,
        currentIndex: previousIndex,
        isLoading: true,
        position: Duration.zero,
      ));

      await _playCurrentPodcast(previousPodcast);

      emit(state.copyWith(
        isLoading: false,
        isPlaying: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _playCurrentPodcast(Podcast podcast) async {
    await _audioPlayer.setSpeed(state.playbackSpeed);
    await _audioPlayer.seek(Duration.zero);
    await _audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(podcast.audioUrl),
        tag: MediaItem(
          id: podcast.id,
          title: podcast.title,
          artUri: Uri.parse(podcast.imageUrl),
        ),
      ),
    );
    await _audioPlayer.play();
  }

  Future<void> _onPausePodcast(
      PausePodcast event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.pause();
    emit(state.copyWith(isPlaying: false));
  }

  Future<void> _onResumePodcast(
      ResumePodcast event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.play();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> _onStopPodcast(
      StopPodcast event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.stop();
    emit(const AudioPlayerState());
  }

  Future<void> _onSeekTo(SeekTo event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.seek(event.position);
  }

  Future<void> _onSetSpeed(
      SetSpeed event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.setSpeed(event.speed);
    emit(state.copyWith(playbackSpeed: event.speed));
  }

  void _onUpdatePosition(UpdatePosition event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onUpdateDuration(UpdateDuration event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onUpdatePlayerState(
      UpdatePlayerState event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(
      isPlaying: event.isPlaying,
      processingState: event.processingState,
    ));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
