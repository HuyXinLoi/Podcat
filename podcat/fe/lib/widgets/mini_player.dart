import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/audio_player/audio_player_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/models/podcast.dart';
import 'package:just_audio/just_audio.dart' as ja;

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioPlayerBloc, AudioPlayerState>(
      listener: (context, state) {
        if (state.hasCurrentPodcast && state.isPlaying && !state.isLoading) {
          if (!_animationController.isAnimating) {
            _animationController.repeat();
          }
        } else {
          if (_animationController.isAnimating) {
            _animationController.stop();
          }
        }
      },
      builder: (context, state) {
        if (!state.hasCurrentPodcast) {
          if (_animationController.isAnimating) {
            _animationController.stop();
          }
          return const SizedBox.shrink();
        }

        final podcast = state.currentPodcast!;

        return GestureDetector(
          onTap: () {
            context.push('/podcast/${podcast.id}/play', extra: podcast);
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // if (state.duration.inSeconds > 0)
                //   LinearProgressIndicator(
                //     value: (state.duration.inSeconds > 0 &&
                //             state.position.inSeconds <=
                //                 state.duration.inSeconds)
                //         ? state.position.inSeconds / state.duration.inSeconds
                //         : 0.0,
                //     backgroundColor: Colors.grey[300],
                //     valueColor: AlwaysStoppedAnimation<Color>(
                //       Theme.of(context).colorScheme.primary,
                //     ),
                //     minHeight: 2,
                //   )
                // else
                //   Container(height: 2),
                Expanded(
                  child: Row(
                    children: [
                      state.isPlaying && !state.isLoading
                          ? RotationTransition(
                              turns: _animationController,
                              child: _buildAlbumArt(podcast),
                            )
                          : _buildAlbumArt(podcast),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              podcast.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    ResponsiveHelper.getFontSize(context, 14.5),
                              ),
                            ),
                            if (podcast.categoryName != null &&
                                podcast.categoryName!.isNotEmpty)
                              Text(
                                podcast.categoryName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: ResponsiveHelper.getFontSize(
                                      context, 12.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                      _buildControls(state, context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArt(Podcast podcast) {
    return ClipOval(
      child: Image.network(
        podcast.imageUrl,
        width: 50,
        height: 51,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: Icon(Icons.music_note, size: 28, color: Colors.grey[600]),
          );
        },
      ),
    );
  }

  Widget _buildControls(AudioPlayerState state, BuildContext context) {
    final bool canInteract = !state.isLoading;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          iconSize: 24,
          onPressed: (state.hasPreviousPodcast && canInteract)
              ? () => context.read<AudioPlayerBloc>().add(PreviousPodcast())
              : null,
          icon: const Icon(Icons.skip_previous),
          color: (state.hasPreviousPodcast && canInteract)
              ? Theme.of(context).iconTheme.color ?? Colors.grey[700]
              : Colors.grey[400],
        ),
        state.isLoading
            ? Container(
                width: 34,
                height: 34,
                padding: const EdgeInsets.all(4),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : IconButton(
                iconSize: 34,
                onPressed: canInteract
                    ? () {
                        if (state.isPlaying) {
                          context.read<AudioPlayerBloc>().add(PausePodcast());
                        } else {
                          if (state.processingState ==
                                  ja.ProcessingState.completed &&
                              state.hasCurrentPodcast) {
                            context.read<AudioPlayerBloc>().add(
                                PlayPodcast(podcast: state.currentPodcast!));
                          } else {
                            context
                                .read<AudioPlayerBloc>()
                                .add(ResumePodcast());
                          }
                        }
                      }
                    : null,
                icon: Icon(
                  state.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                ),
                color: Theme.of(context).colorScheme.primary,
              ),
        IconButton(
          iconSize: 24,
          onPressed: (state.hasNextPodcast && canInteract)
              ? () => context.read<AudioPlayerBloc>().add(NextPodcast())
              : null,
          icon: const Icon(Icons.skip_next),
          color: (state.hasNextPodcast && canInteract)
              ? Theme.of(context).iconTheme.color ?? Colors.grey[700]
              : Colors.grey[400],
        ),
      ],
    );
  }
}
