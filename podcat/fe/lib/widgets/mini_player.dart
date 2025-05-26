import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/audio_player/audio_player_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';

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
        if (state.hasCurrentPodcast && state.isPlaying) {
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
        // final progress = state.duration.inMilliseconds > 0
        //     ? state.position.inMilliseconds / state.duration.inMilliseconds
        //     : 0.0;

        return GestureDetector(
          onTap: () {
            context.push('/podcast/${podcast.id}/play', extra: podcast);
          },
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(12),
              //   topRight: Radius.circular(12),
              // ),
            ),
            child: Column(
              children: [
                // Thanh progress bar (đã comment)
                // LinearProgressIndicator(
                //   value: progress,
                //   backgroundColor: Colors.grey[300],
                //   valueColor: AlwaysStoppedAnimation<Color>(
                //     Theme.of(context).colorScheme.primary,
                //   ),
                //   minHeight: 3,
                // ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      children: [
                        RotationTransition(
                          turns: _animationController,
                          child: ClipOval(
                            child: Image.network(
                              podcast.imageUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                  ),
                                  child: const Icon(Icons.music_note, size: 28),
                                );
                              },
                            ),
                          ),
                        ),
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
                                  fontSize: ResponsiveHelper.getFontSize(
                                      context, 14.5),
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
                        IconButton(
                          iconSize: 34,
                          onPressed: () {
                            if (state.isPlaying) {
                              context
                                  .read<AudioPlayerBloc>()
                                  .add(PausePodcast());
                            } else {
                              if (state.hasCurrentPodcast) {
                                context
                                    .read<AudioPlayerBloc>()
                                    .add(ResumePodcast());
                              }
                            }
                          },
                          icon: state.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5),
                                )
                              : Icon(
                                  state.isPlaying
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_fill_rounded,
                                ),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        IconButton(
                          iconSize: 26,
                          onPressed: () {
                            context.read<AudioPlayerBloc>().add(StopPodcast());
                          },
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
