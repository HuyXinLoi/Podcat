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
  }

  Future<void> _onPlayPodcast(
      PlayPodcast event, Emitter<AudioPlayerState> emit) async {
    try {
      emit(state.copyWith(
        currentPodcast: event.podcast,
        isLoading: true,
        position: Duration.zero,
        playbackSpeed: 1.0,
      ));

      await _audioPlayer.setSpeed(1.0);
      await _audioPlayer.seek(Duration.zero);
      //await _audioPlayer.setUrl(event.podcast.audioUrl);
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(event.podcast.audioUrl),
          tag: MediaItem(
            id: event.podcast.id,
            title: event.podcast.title,
            //artist: event.podcast.author,
            artUri: Uri.parse(event.podcast.imageUrl),
          ),
        ),
      );
      await _audioPlayer.play();

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
