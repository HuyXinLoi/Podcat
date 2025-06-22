import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:podcat/blocs/audio_player/audio_player_bloc.dart';
import 'package:podcat/blocs/favorite/favorite_bloc.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/models/podcast.dart';
import 'package:podcat/widgets/add_to_playlist_dialog.dart';
import 'package:podcat/widgets/comment_bottom_sheet.dart';
import 'package:podcat/widgets/current_playlist_dialog.dart';

class PodcastPlayerScreen extends StatefulWidget {
  final Podcast podcast;

  const PodcastPlayerScreen({super.key, required this.podcast});

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen>
    with SingleTickerProviderStateMixin {
  Duration _lastSavedProgressPosition = Duration.zero;
  String? _listenedPodcastId;
  final _commentController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initOrContinuePlaybackAndLoadDetails();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
  }

  void _initOrContinuePlaybackAndLoadDetails() {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    final currentState = audioPlayerBloc.state;

    Podcast podcastToLoadDetailsFor;

    if (!currentState.hasCurrentPodcast ||
        currentState.currentPodcast!.id != widget.podcast.id) {
      _lastSavedProgressPosition = Duration.zero;
      audioPlayerBloc.add(PlayPodcast(podcast: widget.podcast));
      podcastToLoadDetailsFor = widget.podcast;
    } else {
      podcastToLoadDetailsFor = currentState.currentPodcast!;
    }

    _loadPodcastDetails(podcastToLoadDetailsFor.id);
  }

  void _loadPodcastDetails(String podcastId) {
    context.read<PodcastBloc>().add(LoadComments(podcastId: podcastId));
    context.read<FavoriteBloc>().add(CheckFavoriteStatus(podcastId: podcastId));
  }

  @override
  void dispose() {
    final audioState = context.read<AudioPlayerBloc>().state;
    if (audioState.hasCurrentPodcast) {
      final currentPositionSeconds = audioState.position.inSeconds;
      if (currentPositionSeconds > 0) {
        _saveProgress(audioState.currentPodcast!.id, currentPositionSeconds);
      }
    }
    _commentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _saveProgress(String podcastId, int progressInSeconds) {
    if (progressInSeconds <= 0) return;
    try {
      context.read<PodcastBloc>().add(
            SaveProgress(
              podcastId: podcastId,
              progress: progressInSeconds,
            ),
          );
    } catch (e) {
      //print('Error saving progress: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _toggleFavorite(String podcastId) {
    context.read<FavoriteBloc>().add(ToggleFavorite(podcastId: podcastId));
  }

  void _showCommentBottomSheet(BuildContext ctx, Podcast podcast) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: BlocProvider.of<PodcastBloc>(ctx),
          child: CommentBottomSheet(podcast: podcast),
        );
      },
    );
  }

  void _showCurrentPlaylistDialog(
      BuildContext ctx, AudioPlayerState audioState) {
    if (!audioState.hasCurrentPodcast) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrentPlaylistBottomSheet(
        playlist: audioState.playlist,
        currentIndex: audioState.currentIndex,
        onPlayTrack: (podcast, index) {
          ctx.pop();
          if (audioState.currentPodcast?.id != podcast.id) {
            context.read<AudioPlayerBloc>().add(PlayPodcast(
                  podcast: podcast,
                  playlist: audioState.playlist,
                  startIndex: index,
                ));
          }
        },
      ),
    );
  }

  void _showMoreActionsDialog(BuildContext ctx, Podcast podcast) {
    final l10n = AppLocalizations.of(ctx)!;
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: Text(l10n.addToPlaylist),
                onTap: () {
                  //Navigator.pop(ctx);
                  ctx.pop();
                  showDialog(
                    context: ctx,
                    builder: (dialogContext) =>
                        AddToPlaylistDialog(podcastId: podcast.id),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text(l10n.share),
                onTap: () {
                  //Navigator.pop(ctx);
                  ctx.pop();
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Share functionality not implemented yet.')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Hẹn giờ tắt nhạc'),
                onTap: () {
                  context.pop();
                  _showSleepTimerDialog(context);
                },
              ),
              // Thêm các action khác nếu cần
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nowPlaying),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AudioPlayerBloc, AudioPlayerState>(
            listener: (context, audioState) {
              if (audioState.isPlaying) {
                _animationController.repeat();
              } else {
                _animationController.stop();
              }

              if (audioState.hasCurrentPodcast) {
                if (_listenedPodcastId != audioState.currentPodcast!.id) {
                  _lastSavedProgressPosition = Duration.zero;
                  _listenedPodcastId = audioState.currentPodcast!.id;
                  _loadPodcastDetails(audioState.currentPodcast!.id);
                }

                if (audioState.isPlaying) {
                  final position = audioState.position;
                  if (position.inSeconds > 0 &&
                      position.inSeconds % 10 == 0 &&
                      position != _lastSavedProgressPosition) {
                    _saveProgress(
                        audioState.currentPodcast!.id, position.inSeconds);
                    _lastSavedProgressPosition = position;
                  }
                }
              } else {
                _listenedPodcastId = null;
              }
            },
          ),
          BlocListener<PodcastBloc, PodcastState>(
              listener: (context, podcastState) {
            // if (podcastState.status == PodcastStatus.commentAdded) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(content: Text(l10n.commentAddedSuccessfully)),
            //     );
            // }
          })
        ],
        child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, audioState) {
            final Podcast podcastToDisplay = audioState.hasCurrentPodcast
                ? audioState.currentPodcast!
                : widget.podcast;

            if (audioState.isLoading &&
                (!audioState.hasCurrentPodcast ||
                    audioState.currentPodcast!.id != podcastToDisplay.id ||
                    (audioState.hasCurrentPodcast &&
                        audioState.duration == Duration.zero &&
                        podcastToDisplay.id ==
                            audioState.currentPodcast!.id))) {
              return const Center(child: CircularProgressIndicator());
            }

            return BlocBuilder<PodcastBloc, PodcastState>(
                builder: (context, podcastDetailState) {
              final String description =
                  podcastDetailState.currentPodcast?.id == podcastToDisplay.id
                      ? podcastDetailState.currentPodcast!.description
                      : podcastToDisplay.description;

              return isDesktop
                  ? _buildDesktopLayout(
                      podcastToDisplay, audioState, description, l10n)
                  : _buildMobileLayout(
                      podcastToDisplay, audioState, description, l10n);
            });
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Podcast podcastDetails, AudioPlayerState audioState,
      String description, AppLocalizations l10n) {
    final bool isThisPodcastActiveInBloc = audioState.hasCurrentPodcast &&
        audioState.currentPodcast!.id == podcastDetails.id;

    final bool isPlaying = isThisPodcastActiveInBloc && audioState.isPlaying;
    final Duration position =
        isThisPodcastActiveInBloc ? audioState.position : Duration.zero;
    final Duration duration =
        isThisPodcastActiveInBloc ? audioState.duration : Duration.zero;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _animationController,
                    child: ClipOval(
                      //borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        podcastDetails.imageUrl,
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.7,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.width * 0.7,
                            color: Colors.grey[300],
                            child: const Icon(Icons.headphones,
                                size: 80, color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      podcastDetails.title,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (podcastDetails.categoryName != null &&
                      podcastDetails.categoryName!.isNotEmpty)
                    Text(
                      podcastDetails.categoryName!,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      description,
                      style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 14)),
                      textAlign: TextAlign.justify,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildPlayerControls(
            podcastDetails, isPlaying, position, duration, audioState, l10n),
      ],
    );
  }

  Widget _buildDesktopLayout(Podcast podcastDetails,
      AudioPlayerState audioState, String description, AppLocalizations l10n) {
    final bool isThisPodcastActiveInBloc = audioState.hasCurrentPodcast &&
        audioState.currentPodcast!.id == podcastDetails.id;
    final bool isPlaying = isThisPodcastActiveInBloc && audioState.isPlaying;
    final Duration position =
        isThisPodcastActiveInBloc ? audioState.position : Duration.zero;
    final Duration duration =
        isThisPodcastActiveInBloc ? audioState.duration : Duration.zero;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: RotationTransition(
              turns: _animationController,
              child: ClipOval(
                //orderRadius: BorderRadius.circular(16),
                child: Image.network(
                  podcastDetails.imageUrl,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.headphones,
                          size: 120, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  podcastDetails.title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 28),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (podcastDetails.categoryName != null &&
                    podcastDetails.categoryName!.isNotEmpty)
                  Text(
                    podcastDetails.categoryName!,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      description,
                      style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildPlayerControls(podcastDetails, isPlaying, position,
                    duration, audioState, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls(
      Podcast displayedPodcast,
      bool isPlaying,
      Duration position,
      Duration duration,
      AudioPlayerState audioStateGlobal,
      AppLocalizations l10n) {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    final currentSpeed = audioStateGlobal.playbackSpeed;
    final bool isDisplayedPodcastCurrentlyActiveInBloc =
        audioStateGlobal.hasCurrentPodcast &&
            audioStateGlobal.currentPodcast!.id == displayedPodcast.id;
    final bool isLoadingDisplayedPodcast =
        audioStateGlobal.isLoading && isDisplayedPodcastCurrentlyActiveInBloc;

    final bool canControl =
        isDisplayedPodcastCurrentlyActiveInBloc && !isLoadingDisplayedPodcast;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position)),
              Text(_formatDuration(duration)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 1,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.onPrimary,
              thumbColor: Theme.of(context).colorScheme.primary,
            ),
            child: Slider(
              value: (duration.inSeconds > 0)
                  ? position.inSeconds
                      .toDouble()
                      .clamp(0.0, duration.inSeconds.toDouble())
                  : 0.0,
              min: 0,
              max: (duration.inSeconds > 0)
                  ? duration.inSeconds.toDouble()
                  : 1.0,
              onChanged: canControl
                  ? (value) {
                      audioPlayerBloc.add(
                        SeekTo(position: Duration(seconds: value.toInt())),
                      );
                    }
                  : null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRepeatButton(context, audioStateGlobal, canControl),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: ResponsiveHelper.isMobile(context) ? 30 : 36,
                onPressed: (audioStateGlobal.hasPreviousPodcast && canControl)
                    ? () => audioPlayerBloc.add(PreviousPodcast())
                    : null,
              ),
              // IconButton(
              //   icon: const Icon(Icons.replay_10),
              //   iconSize: ResponsiveHelper.isMobile(context) ? 30 : 36,
              //   onPressed: canControl
              //       ? () {
              //           final newPos = audioStateGlobal.position -
              //               const Duration(seconds: 10);
              //           audioPlayerBloc.add(SeekTo(
              //               position:
              //                   newPos.isNegative ? Duration.zero : newPos));
              //         }
              //       : null,
              // ),
              isLoadingDisplayedPodcast
                  ? SizedBox(
                      width: ResponsiveHelper.isMobile(context) ? 56 : 72,
                      height: ResponsiveHelper.isMobile(context) ? 56 : 72,
                      child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Theme.of(context).colorScheme.primary)),
                    )
                  : IconButton(
                      icon: Icon(isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled),
                      iconSize: ResponsiveHelper.isMobile(context) ? 56 : 72,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        if (isPlaying) {
                          audioPlayerBloc.add(PausePodcast());
                        } else {
                          if (isDisplayedPodcastCurrentlyActiveInBloc &&
                              audioStateGlobal.processingState ==
                                  ja.ProcessingState.completed) {
                            _lastSavedProgressPosition = Duration.zero;
                            audioPlayerBloc
                                .add(PlayPodcast(podcast: displayedPodcast));
                          } else if (!isDisplayedPodcastCurrentlyActiveInBloc) {
                            _lastSavedProgressPosition = Duration.zero;
                            audioPlayerBloc
                                .add(PlayPodcast(podcast: displayedPodcast));
                          } else {
                            audioPlayerBloc.add(ResumePodcast());
                          }
                        }
                      },
                    ),

              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: ResponsiveHelper.isMobile(context) ? 30 : 36,
                onPressed: (audioStateGlobal.hasNextPodcast && canControl)
                    ? () => audioPlayerBloc.add(NextPodcast())
                    : null,
              ),
              // IconButton(
              //   icon: const Icon(Icons.forward_30),
              //   iconSize: ResponsiveHelper.isMobile(context) ? 30 : 36,
              //   onPressed: canControl
              //       ? () {
              //           final newPos = audioStateGlobal.position +
              //               const Duration(seconds: 30);
              //           audioPlayerBloc.add(SeekTo(
              //               position: newPos > audioStateGlobal.duration
              //                   ? audioStateGlobal.duration
              //                   : newPos));
              //         }
              //       : null,
              // ),
              IconButton(
                icon: const Icon(Icons.playlist_play_outlined),
                onPressed: (audioStateGlobal.playlist.isNotEmpty && canControl)
                    ? () =>
                        _showCurrentPlaylistDialog(context, audioStateGlobal)
                    : null,
                tooltip: 'abcd',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // NÚT FAVORITE
              BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, favoriteState) {
                  bool isFavorited =
                      favoriteState.isFavorite(displayedPodcast.id);

                  return IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: canControl
                        ? () => _toggleFavorite(displayedPodcast.id)
                        : null,
                    tooltip: l10n.favorites,
                  );
                },
              ),

              // NÚT COMMENT
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: canControl
                    ? () => _showCommentBottomSheet(context, displayedPodcast)
                    : null,
                tooltip: l10n.comments,
              ),

              // NÚT SPEED
              TextButton.icon(
                icon: const Icon(Icons.speed, size: 20),
                label: Text('${currentSpeed}x'),
                onPressed: canControl
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Chọn tốc độ'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
                                    .map((speed) => ListTile(
                                          title: Text('${speed}x'),
                                          onTap: () {
                                            audioPlayerBloc
                                                .add(SetSpeed(speed: speed));
                                            Navigator.of(context).pop();
                                          },
                                          selected: currentSpeed == speed,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        );
                      }
                    : null,
                style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).textTheme.bodyLarge?.color),
              ),

              // NÚT HẸN GIỜ TẮT NHẠC
              IconButton(
                icon: const Icon(Icons.timer),
                onPressed:
                    canControl ? () => _showSleepTimerDialog(context) : null,
                tooltip: 'Hẹn giờ tắt nhạc',
              ),

              // NÚT THÊM VÀO PLAYLIST
              IconButton(
                icon: const Icon(Icons.playlist_add),
                onPressed: canControl
                    ? () => showDialog(
                          context: context,
                          builder: (dialogContext) => AddToPlaylistDialog(
                              podcastId: displayedPodcast.id),
                        )
                    : null,
                tooltip: 'Thêm vào Playlist',
              ),

              // NÚT MORE ACTIONS
              // IconButton(
              //   icon: const Icon(Icons.more_horiz_outlined),
              //   onPressed: canControl
              //       ? () => _showMoreActionsDialog(context, displayedPodcast)
              //       : null,
              //   tooltip: 'More Actions',
              // ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.timer_10),
              title: const Text('Tắt sau 10 phút'),
              onTap: () {
                context
                    .read<AudioPlayerBloc>()
                    .add(SetSleepTimer(Duration(minutes: 10)));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nhạc sẽ tắt sau 10 phút')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_10_sharp),
              title: const Text('Tắt sau 30 phút'),
              onTap: () {
                context
                    .read<AudioPlayerBloc>()
                    .add(SetSleepTimer(Duration(minutes: 30)));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nhạc sẽ tắt sau 30 phút')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Huỷ hẹn giờ'),
              onTap: () {
                context.read<AudioPlayerBloc>().add(CancelSleepTimer());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã huỷ hẹn giờ')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatButton(
      BuildContext context, AudioPlayerState audioState, bool canControl) {
    final currentMode = audioState.repeatMode;

    IconData icon;
    String tooltip;

    // Xác định icon và tooltip dựa trên chế độ hiện tại
    switch (currentMode) {
      case AudioServiceRepeatMode.none:
        icon = Icons.repeat;
        tooltip = 'Đã tắt lặp lại';
        break;
      case AudioServiceRepeatMode.all:
        icon = Icons.repeat;
        tooltip = 'Lặp lại danh sách phát';
        break;
      case AudioServiceRepeatMode.one:
        icon = Icons.repeat_one;
        tooltip = 'Lặp lại bài hát này';
        break;
      default:
        icon = Icons.repeat;
        tooltip = 'Chế độ lặp lại';
    }

    // Xác định hành động khi nhấn nút
    void handleTap() {
      final bloc = context.read<AudioPlayerBloc>();
      String message;
      switch (currentMode) {
        case AudioServiceRepeatMode.none:
          bloc.add(SetRepeatMode(AudioServiceRepeatMode.all));
          message = 'Đã bật lặp lại danh sách phát';
          break;
        case AudioServiceRepeatMode.all:
          bloc.add(SetRepeatMode(AudioServiceRepeatMode.one));
          message = 'Đã bật lặp lại bài hát';
          break;
        case AudioServiceRepeatMode.one:
          bloc.add(SetRepeatMode(AudioServiceRepeatMode.none));
          message = 'Đã tắt chế độ lặp lại';
          break;
        default:
          bloc.add(SetRepeatMode(AudioServiceRepeatMode.none));
          message = 'Đã tắt chế độ lặp lại';
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ));
    }

    return IconButton(
      icon: Icon(icon),
      iconSize: ResponsiveHelper.isMobile(context) ? 28 : 32,
      tooltip: tooltip,
      // Nút sẽ có màu primary khi đang bật một chế độ lặp lại nào đó
      color: currentMode == AudioServiceRepeatMode.none
          ? Theme.of(context).iconTheme.color
          : Theme.of(context).colorScheme.primary,
      onPressed: canControl ? handleTap : null,
    );
  }
}
