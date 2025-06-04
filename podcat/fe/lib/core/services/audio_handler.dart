import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.podcat.audio',
      androidNotificationChannelName: 'Podcat Audio',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      androidNotificationIcon: "drawable/launcher_icon",
      artDownscaleWidth: 200,
      artDownscaleHeight: 200,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  Function()? onNext;
  Function()? onPrevious;
  Function(bool)? onPlayPauseChanged;

  MediaItem? _currentMediaItemForHandler;

  bool _hasNext = false;
  bool _hasPrevious = false;

  MyAudioHandler() {
    _init();
  }

  void _init() {
    playbackState.add(playbackState.value.copyWith(
      controls: _getControls(),
      processingState: AudioProcessingState.idle,
      playing: false,
      updatePosition: Duration.zero,
      speed: 1.0,
      systemActions: _getSystemActions(),
    ));

    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = _mapProcessingState(playerState.processingState);

      playbackState.add(playbackState.value.copyWith(
        controls: _getControls(),
        systemActions: _getSystemActions(),
        playing: isPlaying,
        processingState: processingState,
        speed: _player.speed,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
      ));
      onPlayPauseChanged?.call(isPlaying);
    });

    _player.durationStream.listen((duration) {
      if (mediaItem.value != null) {
        mediaItem.add(
            mediaItem.value!.copyWith(duration: duration ?? Duration.zero));
      }
    });
  }

  Set<MediaAction> _getSystemActions() {
    final actions = <MediaAction>{
      MediaAction.seek,
      MediaAction.seekForward,
      MediaAction.seekBackward,
      MediaAction.setSpeed,
    };
    if (_hasNext) {
      actions.add(MediaAction.skipToNext);
    }
    if (_hasPrevious) {
      actions.add(MediaAction.skipToPrevious);
    }
    if (_player.playing) {
      actions.add(MediaAction.pause);
    } else {
      actions.add(MediaAction.play);
    }
    return actions;
  }

  List<MediaControl> _getControls() {
    return [
      MediaControl.skipToPrevious,
      const MediaControl(
        androidIcon: 'drawable/ic_replay_10',
        label: 'Replay 10s',
        action: MediaAction.seekBackward,
      ),
      if (_player.playing) MediaControl.pause else MediaControl.play,
      const MediaControl(
        androidIcon: 'drawable/ic_forward_30',
        label: 'Forward 30s',
        action: MediaAction.seekForward,
      ),
      MediaControl.skipToNext,
    ];
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> updateMediaItem(MediaItem newItem) async {
    final currentItemId = mediaItem.value?.id;
    mediaItem.add(newItem);
    if (newItem.id.isNotEmpty && newItem.id != currentItemId) {
      try {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(newItem.id)));
      } catch (e) {
        playbackState.add(playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
        ));
      }
    }
    _currentMediaItemForHandler = newItem;
  }

  void updatePlaylistState({
    required bool hasNext,
    required bool hasPrevious,
  }) {
    _hasNext = hasNext;
    _hasPrevious = hasPrevious;
    final newPosition = Duration.zero;

    playbackState.add(playbackState.value.copyWith(
      controls: _getControls(),
      systemActions: _getSystemActions(),
      updatePosition: newPosition,
    ));
  }

  void setCallbacks({
    Function()? onNext,
    Function()? onPrevious,
    Function(bool)? onPlayPauseChanged,
  }) {
    this.onNext = onNext;
    this.onPrevious = onPrevious;
    this.onPlayPauseChanged = onPlayPauseChanged;
  }

  AudioPlayer get audioPlayer => _player;

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() async {
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
        systemActions: _getSystemActions()));
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_hasNext) onNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_hasPrevious) onPrevious?.call();
  }

  @override
  Future<void> seekForward(bool begin) async {
    if (begin) {
      final currentPosition = _player.position;
      final newPosition = currentPosition + const Duration(seconds: 30);
      final duration = _player.duration ?? Duration.zero;
      await _player.seek(newPosition > duration ? duration : newPosition);
    }
  }

  @override
  Future<void> seekBackward(bool begin) async {
    if (begin) {
      final currentPosition = _player.position;
      final newPosition = currentPosition - const Duration(seconds: 10);
      await _player.seek(newPosition.isNegative ? Duration.zero : newPosition);
    }
  }

  @override
  Future<void> customAction(String name,
      [Map<String, dynamic>? extras]) async {}

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    playbackState.add(playbackState.value.copyWith(speed: speed));
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}
