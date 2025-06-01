// import 'package:audio_service/audio_service.dart';
// import 'package:just_audio/just_audio.dart';

// Future<AudioHandler> initAudioService() async {
//   return await AudioService.init(
//     builder: () => MyAudioHandler(),
//     config: const AudioServiceConfig(
//       androidNotificationChannelId: 'com.podcat.audio',
//       androidNotificationChannelName: 'Podcat Audio',
//       androidNotificationOngoing: true,
//       androidShowNotificationBadge: true,
//       androidStopForegroundOnPause: true,
//       artDownscaleWidth: 200,
//       artDownscaleHeight: 200,
//     ),
//   );
// }

// class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
//   final _player = AudioPlayer();
  
//   // Callback functions để giao tiếp với AudioPlayerBloc
//   Function()? onNext;
//   Function()? onPrevious;
//   Function()? onToggleFavorite;
//   Function(bool)? onPlayPauseChanged;
  
//   // State tracking
//   bool _isFavorite = false;
//   bool _hasNext = false;
//   bool _hasPrevious = false;

//   MyAudioHandler() {
//     _init();
//   }

//   void _init() {
//     // Listen to player state changes
//     _player.playerStateStream.listen((state) {
//       final isPlaying = state.playing;
//       final processingState = state.processingState;
      
//       playbackState.add(playbackState.value.copyWith(
//         controls: _getControls(),
//         systemActions: const {
//           MediaAction.seek,
//           MediaAction.seekForward,
//           MediaAction.seekBackward,
//         },
//         playing: isPlaying,
//         processingState: _mapProcessingState(processingState),
//         speed: _player.speed,
//         updatePosition: _player.position,
//       ));
      
//       // Notify về play/pause state change
//       onPlayPauseChanged?.call(isPlaying);
//     });

//     // Listen to position changes
//     _player.positionStream.listen((position) {
//       playbackState.add(playbackState.value.copyWith(
//         updatePosition: position,
//       ));
//     });

//     // Listen to duration changes
//     _player.durationStream.listen((duration) {
//       if (duration != null) {
//         mediaItem.add(mediaItem.value?.copyWith(
//           duration: duration,
//         ));
//       }
//     });
//   }

//   List<MediaControl> _getControls() {
//     List<MediaControl> controls = [];
    
//     // Previous button
//     if (_hasPrevious) {
//       controls.add(MediaControl.skipToPrevious);
//     }
    
//     // Seek backward
//     controls.add(const MediaControl(
//       androidIcon: 'drawable/ic_replay_10',
//       label: 'Replay 10s',
//       action: MediaAction.seekBackward,
//     ));
    
//     // Play/Pause
//     controls.add(_player.playing ? MediaControl.pause : MediaControl.play);
    
//     // Seek forward
//     controls.add(const MediaControl(
//       androidIcon: 'drawable/ic_forward_30',
//       label: 'Forward 30s',
//       action: MediaAction.seekForward,
//     ));
    
//     // Next button
//     if (_hasNext) {
//       controls.add(MediaControl.skipToNext);
//     }
    
//     // Love/Favorite button
//     controls.add(MediaControl(
//       androidIcon: _isFavorite ? 'drawable/ic_favorite' : 'drawable/ic_favorite_border',
//       label: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
//       action: MediaAction.custom,
//       customAction: const CustomMediaAction('toggle_favorite', 'Toggle Favorite'),
//     ));

//     return controls;
//   }

//   AudioProcessingState _mapProcessingState(ProcessingState state) {
//     switch (state) {
//       case ProcessingState.idle:
//         return AudioProcessingState.idle;
//       case ProcessingState.loading:
//         return AudioProcessingState.loading;
//       case ProcessingState.buffering:
//         return AudioProcessingState.buffering;
//       case ProcessingState.ready:
//         return AudioProcessingState.ready;
//       case ProcessingState.completed:
//         return AudioProcessingState.completed;
//     }
//   }

//   // Public methods để update state từ AudioPlayerBloc
//   void updateMediaItem(MediaItem item) {
//     mediaItem.add(item);
//   }

//   void updatePlaylistState({
//     required bool hasNext,
//     required bool hasPrevious,
//     required bool isFavorite,
//   }) {
//     _hasNext = hasNext;
//     _hasPrevious = hasPrevious;
//     _isFavorite = isFavorite;
    
//     // Update controls
//     playbackState.add(playbackState.value.copyWith(
//       controls: _getControls(),
//     ));
//   }

//   void setCallbacks({
//     Function()? onNext,
//     Function()? onPrevious,
//     Function()? onToggleFavorite,
//     Function(bool)? onPlayPauseChanged,
//   }) {
//     this.onNext = onNext;
//     this.onPrevious = onPrevious;
//     this.onToggleFavorite = onToggleFavorite;
//     this.onPlayPauseChanged = onPlayPauseChanged;
//   }

//   Future<void> playMediaItem(MediaItem item) async {
//     mediaItem.add(item);
//     await _player.setAudioSource(AudioSource.uri(
//       Uri.parse(item.id),
//       tag: item,
//     ));
//     await _player.play();
//   }

//   @override
//   Future<void> play() async {
//     await _player.play();
//   }

//   @override
//   Future<void> pause() async {
//     await _player.pause();
//   }

//   @override
//   Future<void> stop() async {
//     await _player.stop();
//     await super.stop();
//   }

//   @override
//   Future<void> seek(Duration position) async {
//     await _player.seek(position);
//   }

//   @override
//   Future<void> skipToNext() async {
//     onNext?.call();
//   }

//   @override
//   Future<void> skipToPrevious() async {
//     onPrevious?.call();
//   }

//   @override
//   Future<void> seekForward(bool begin) async {
//     if (begin) {
//       final currentPosition = _player.position;
//       final newPosition = currentPosition + const Duration(seconds: 30);
//       final duration = _player.duration ?? Duration.zero;
//       await _player.seek(newPosition > duration ? duration : newPosition);
//     }
//   }

//   @override
//   Future<void> seekBackward(bool begin) async {
//     if (begin) {
//       final currentPosition = _player.position;
//       final newPosition = currentPosition - const Duration(seconds: 10);
//       await _player.seek(newPosition.isNegative ? Duration.zero : newPosition);
//     }
//   }

//   @override
//   Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
//     switch (name) {
//       case 'toggle_favorite':
//         onToggleFavorite?.call();
//         break;
//     }
//   }

//   @override
//   Future<void> setSpeed(double speed) async {
//     await _player.setSpeed(speed);
//   }

//   @override
//   Future<void> onTaskRemoved() async {
//     await stop();
//   }

//   @override
//   Future<void> onNotificationDeleted() async {
//     await stop();
//   }

//   @override
//   Future<void> dispose() async {
//     await _player.dispose();
//     await super.stop();
//   }
// }

// // Custom media action class
// class CustomMediaAction {
//   final String action;
//   final String label;
  
//   const CustomMediaAction(this.action, this.label);
// }
