import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:podcat/core/services/audio_handler.dart';
import 'package:podcat/models/podcast.dart';

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  MyAudioHandler? _audioHandler;
  bool _isChangingTrack = false;
  Timer? _sleepTimer;

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
    on<SetSleepTimer>(_onSetSleepTimer);
    on<CancelSleepTimer>(_onCancelSleepTimer);
    on<SetRepeatMode>((event, emit) async {
      await _audioHandler?.setRepeatMode(event.mode);
      emit(state.copyWith(repeatMode: event.mode));
    });

    // on<ToggleFavoriteFromNotification>(_onToggleFavoriteFromNotification);

    _initializeAudioService();
  }

  Future<void> _initializeAudioService() async {
    try {
      _audioHandler = await initAudioService() as MyAudioHandler;
      _audioHandler?.setCallbacks(
        onNext: () => add(NextPodcast()),
        onPrevious: () => add(PreviousPodcast()),
        // onToggleFavorite: () => add(ToggleFavoriteFromNotification()),
        onPlayPauseChanged: (isPlaying) {
          // This callback can be used to sync if AudioHandler directly changes play/pause
        },
      );

      _initializeAudioPlayer();
    } catch (e) {
      print('Error initializing audio service: $e');
    }
  }

  void _initializeAudioPlayer() {
    if (_audioHandler == null) {
      return;
    }

    final audioPlayer = _audioHandler!.audioPlayer;

    audioPlayer.playerStateStream.listen((playerState) {
      if (!_isChangingTrack) {
        add(UpdatePlayerState(
          isPlaying: playerState.playing,
          processingState: playerState.processingState,
        ));
        // if (playerState.processingState == ProcessingState.completed &&
        //     state.hasNextPodcast) {
        //   add(NextPodcast());
        // }
        if (playerState.processingState == ProcessingState.completed) {
          if (state.hasNextPodcast) {
            add(NextPodcast());
          } else if (state.repeatMode == AudioServiceRepeatMode.all &&
              state.playlist.isNotEmpty) {
            add(PlayPlaylist(playlist: state.playlist, startIndex: 0));
          }
        }
      }
    });

    audioPlayer.positionStream.listen((position) {
      if (!_isChangingTrack) {
        add(UpdatePosition(position));
      }
    });

    audioPlayer.durationStream.listen((duration) {
      if (duration != null && !_isChangingTrack) {
        add(UpdateDuration(duration));
      }
    });
  }

  void _updateAudioServiceState() {
    if (_audioHandler != null && state.hasCurrentPodcast) {
      final podcast = state.currentPodcast!;
      final newMediaId = podcast.audioUrl;
      final mediaItem = MediaItem(
        id: newMediaId,
        title: podcast.title,
        artist: podcast.categoryName ?? 'Podcast',
        artUri: Uri.parse(podcast.imageUrl),
        duration: state.duration,
      );
      _audioHandler!.updateMediaItem(mediaItem);

      _audioHandler!.updatePlaylistState(
        hasNext: state.hasNextPodcast,
        hasPrevious: state.hasPreviousPodcast,
      );
    }
  }

  Future<void> _onPlayPodcast(
      PlayPodcast event, Emitter<AudioPlayerState> emit) async {
    if (_isChangingTrack || _audioHandler == null) return;

    try {
      _isChangingTrack = true;

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
        playbackSpeed: state.playbackSpeed,
        error: null,
      ));

      await _playCurrentPodcast(event.podcast);

      emit(state.copyWith(
        isLoading: false,
        isPlaying: true,
      ));

      _updateAudioServiceState();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    } finally {
      _isChangingTrack = false;
    }
  }

  Future<void> _onPlayPlaylist(
      PlayPlaylist event, Emitter<AudioPlayerState> emit) async {
    if (event.playlist.isEmpty || _isChangingTrack) return;

    final podcast = event.playlist[event.startIndex];
    add(PlayPodcast(
      podcast: podcast,
      playlist: event.playlist,
      startIndex: event.startIndex,
    ));
  }

  Future<void> _onNextPodcast(
      NextPodcast event, Emitter<AudioPlayerState> emit) async {
    if (_audioHandler == null) {
      return;
    }
    if (_isChangingTrack) {
      return;
    }
    if (!state.hasNextPodcast) {
      return;
    }

    try {
      _isChangingTrack = true;
      final nextIndex = state.currentIndex + 1;
      final nextPodcast = state.playlist[nextIndex];
      emit(state.copyWith(
        currentPodcast: nextPodcast,
        currentIndex: nextIndex,
        isLoading: true,
        position: Duration.zero,
        //duration: Duration.zero,
        error: null,
      ));
      await _playCurrentPodcast(nextPodcast);
      emit(state.copyWith(
        isLoading: false,
        isPlaying: true,
      ));
      _updateAudioServiceState();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    } finally {
      _isChangingTrack = false;
    }
  }

  Future<void> _onPreviousPodcast(
      PreviousPodcast event, Emitter<AudioPlayerState> emit) async {
    if (_audioHandler == null) {
      return;
    }
    if (_isChangingTrack) {
      return;
    }
    if (!state.hasPreviousPodcast) {
      return;
    }

    try {
      _isChangingTrack = true;

      final previousIndex = state.currentIndex - 1;
      final previousPodcast = state.playlist[previousIndex];

      emit(state.copyWith(
        currentPodcast: previousPodcast,
        currentIndex: previousIndex,
        isLoading: true,
        position: Duration.zero,
        duration: Duration.zero,
        error: null,
      ));

      await _playCurrentPodcast(previousPodcast);

      emit(state.copyWith(
        isLoading: false,
        isPlaying: true,
      ));

      _updateAudioServiceState();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    } finally {
      _isChangingTrack = false;
    }
  }

  Future<void> _playCurrentPodcast(Podcast podcast) async {
    if (_audioHandler == null) return;
    try {
      final audioPlayer = _audioHandler!.audioPlayer;
      await audioPlayer.stop();
      await audioPlayer.setSpeed(state.playbackSpeed);

      audioPlayer.play();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _onPausePodcast(
      PausePodcast event, Emitter<AudioPlayerState> emit) async {
    if (_isChangingTrack || _audioHandler == null || !state.isPlaying) return;

    try {
      await _audioHandler!.pause();
      emit(state.copyWith(isPlaying: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onResumePodcast(
      ResumePodcast event, Emitter<AudioPlayerState> emit) async {
    if (_isChangingTrack || _audioHandler == null || state.isPlaying) return;

    try {
      await _audioHandler!.play();
      emit(state.copyWith(isPlaying: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onStopPodcast(
      StopPodcast event, Emitter<AudioPlayerState> emit) async {
    if (_audioHandler == null) return;
    _isChangingTrack = true;
    try {
      await _audioHandler!.stop();
      emit(const AudioPlayerState());
    } catch (e) {
      emit(const AudioPlayerState(error: "Failed to stop player"));
    } finally {
      _isChangingTrack = false;
    }
  }

  Future<void> _onSeekTo(SeekTo event, Emitter<AudioPlayerState> emit) async {
    if (_isChangingTrack || _audioHandler == null) return;
    try {
      await _audioHandler!.seek(event.position);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSetSpeed(
      SetSpeed event, Emitter<AudioPlayerState> emit) async {
    if (_isChangingTrack || _audioHandler == null) return;
    try {
      await _audioHandler!.setSpeed(event.speed);
      emit(state.copyWith(playbackSpeed: event.speed));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onUpdatePosition(UpdatePosition event, Emitter<AudioPlayerState> emit) {
    if (!_isChangingTrack) {
      emit(state.copyWith(position: event.position));
    }
  }

  void _onUpdateDuration(UpdateDuration event, Emitter<AudioPlayerState> emit) {
    if (!_isChangingTrack) {
      if (state.duration != event.duration || event.duration != Duration.zero) {
        emit(state.copyWith(duration: event.duration));
        _updateAudioServiceState();
      }
    }
  }

  void _onUpdatePlayerState(
      UpdatePlayerState event, Emitter<AudioPlayerState> emit) {
    if (!_isChangingTrack) {
      emit(state.copyWith(
        isPlaying: event.isPlaying,
        processingState: event.processingState,
      ));
    }
  }

  void _onSetSleepTimer(SetSleepTimer event, Emitter<AudioPlayerState> emit) {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(event.duration, () {
      _audioHandler?.stop(); // Dừng nhạc
    });
  }

  void _onCancelSleepTimer(
      CancelSleepTimer event, Emitter<AudioPlayerState> emit) {
    _sleepTimer?.cancel();
  }

  // void _onToggleFavoriteFromNotification( // Removed
  //     ToggleFavoriteFromNotification event, Emitter<AudioPlayerState> emit) {}

  @override
  Future<void> close() {
    _audioHandler?.stop();
    return super.close();
  }
}
