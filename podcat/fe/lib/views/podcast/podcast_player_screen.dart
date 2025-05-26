import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:podcat/blocs/audio_player/audio_player_bloc.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/models/podcast.dart';

class PodcastPlayerScreen extends StatefulWidget {
  final Podcast podcast;

  const PodcastPlayerScreen({super.key, required this.podcast});

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  @override
  void initState() {
    super.initState();
    _initOrContinuePlayback();
  }

  void _initOrContinuePlayback() {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    final currentState = audioPlayerBloc.state;
    if (currentState.hasCurrentPodcast &&
        currentState.currentPodcast!.id == widget.podcast.id) {
    } else {
      audioPlayerBloc.add(PlayPodcast(podcast: widget.podcast));
    }
  }

  void _saveProgress(int progress) {
    try {
      context.read<PodcastBloc>().add(
            SaveProgress(
              podcastId: widget.podcast.id,
              progress: progress,
            ),
          );
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  @override
  void dispose() {
    final currentPositionSeconds =
        context.read<AudioPlayerBloc>().state.position.inSeconds;
    if (currentPositionSeconds > 0) {
      _saveProgress(currentPositionSeconds);
    }
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nowPlaying),
      ),
      body: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, audioState) {
          if (!audioState.hasCurrentPodcast ||
              audioState.currentPodcast!.id != widget.podcast.id) {
            if (audioState.isLoading &&
                audioState.currentPodcast?.id == widget.podcast.id) {
              return const Center(child: CircularProgressIndicator());
            }
          }
          final displayPodcast = audioState.hasCurrentPodcast &&
                  audioState.currentPodcast!.id == widget.podcast.id
              ? audioState.currentPodcast!
              : widget.podcast;
          final isPlaying = audioState.hasCurrentPodcast &&
                  audioState.currentPodcast!.id == widget.podcast.id
              ? audioState.isPlaying
              : false;
          final position = audioState.hasCurrentPodcast &&
                  audioState.currentPodcast!.id == widget.podcast.id
              ? audioState.position
              : Duration.zero;
          final duration = audioState.hasCurrentPodcast &&
                  audioState.currentPodcast!.id == widget.podcast.id
              ? audioState.duration
              : Duration.zero;
          final isLoading = audioState.hasCurrentPodcast &&
                  audioState.currentPodcast!.id == widget.podcast.id
              ? audioState.isLoading
              : false;

          if (isPlaying &&
              position.inSeconds > 0 &&
              position.inSeconds % 10 == 0) {
            _saveProgress(position.inSeconds);
          }

          return isDesktop
              ? _buildDesktopLayout(displayPodcast, isPlaying, position,
                  duration, isLoading, l10n)
              : _buildMobileLayout(displayPodcast, isPlaying, position,
                  duration, isLoading, l10n);
        },
      ),
    );
  }

  Widget _buildMobileLayout(
      Podcast podcastDetails,
      bool isPlaying,
      Duration position,
      Duration duration,
      bool isLoading,
      AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                        child: const Icon(
                          Icons.headphones,
                          size: 80,
                          color: Colors.white,
                        ),
                      );
                    },
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
                if (podcastDetails.categoryName != null)
                  Text(
                    podcastDetails.categoryName!,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
        _buildPlayerControls(isPlaying, position, duration, isLoading, l10n),
      ],
    );
  }

  Widget _buildDesktopLayout(
      Podcast podcastDetails,
      bool isPlaying,
      Duration position,
      Duration duration,
      bool isLoading,
      AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                podcastDetails.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.headphones,
                      size: 120,
                      color: Colors.white,
                    ),
                  );
                },
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
                if (podcastDetails.categoryName != null)
                  Text(
                    podcastDetails.categoryName!,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  podcastDetails.description,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 32),
                _buildPlayerControls(
                    isPlaying, position, duration, isLoading, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls(bool isPlaying, Duration position,
      Duration duration, bool isLoading, AppLocalizations l10n) {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    final currentSpeed = audioPlayerBloc.state.playbackSpeed;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
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
          Slider(
            value: position.inSeconds.toDouble().clamp(
                0.0,
                duration.inSeconds.toDouble() > 0
                    ? duration.inSeconds.toDouble()
                    : 1.0),
            min: 0,
            max: duration.inSeconds.toDouble() > 0
                ? duration.inSeconds.toDouble()
                : 1.0,
            onChanged: (value) {
              audioPlayerBloc
                  .add(SeekTo(position: Duration(seconds: value.toInt())));
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: ResponsiveHelper.isMobile(context) ? 32 : 40,
                onPressed: () {
                  final newPosition = position - const Duration(seconds: 10);
                  audioPlayerBloc.add(SeekTo(
                      position: newPosition.isNegative
                          ? Duration.zero
                          : newPosition));
                },
              ),
              const SizedBox(width: 16),
              if (isLoading)
                SizedBox(
                    width: ResponsiveHelper.isMobile(context) ? 64 : 80,
                    height: ResponsiveHelper.isMobile(context) ? 64 : 80,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    )))
              else
                IconButton(
                  icon: Icon(isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled),
                  iconSize: ResponsiveHelper.isMobile(context) ? 64 : 80,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (isPlaying) {
                      audioPlayerBloc.add(PausePodcast());
                    } else {
                      if (audioPlayerBloc.state.processingState ==
                          ja.ProcessingState.completed) {
                        audioPlayerBloc
                            .add(PlayPodcast(podcast: widget.podcast));
                      } else {
                        audioPlayerBloc.add(ResumePodcast());
                      }
                    }
                  },
                ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_30),
                iconSize: ResponsiveHelper.isMobile(context) ? 32 : 40,
                onPressed: () {
                  final newPosition = position + const Duration(seconds: 30);
                  audioPlayerBloc.add(SeekTo(
                      position:
                          newPosition > duration ? duration : newPosition));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.speed, size: 20),
              const SizedBox(width: 8),
              DropdownButton<double>(
                value: currentSpeed,
                items: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
                    .map((speed) => DropdownMenuItem(
                          value: speed,
                          child: Text('${speed}x'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    audioPlayerBloc.add(SetSpeed(speed: value));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
