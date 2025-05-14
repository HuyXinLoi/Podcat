import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.podcast.audioUrl);
      _audioPlayer.playerStateStream.listen((state) {
        if (state.playing != _isPlaying) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });

      _audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          setState(() {
            _duration = duration;
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });

      // Save progress periodically
      _audioPlayer.positionStream.listen((position) {
        if (position.inSeconds % 10 == 0) {
          // Save every 10 seconds
          _saveProgress(position.inSeconds);
        }
      });

      _audioPlayer.play();
    } catch (e) {
      print('Error initializing audio player: $e');
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
    _saveProgress(_position.inSeconds);
    _audioPlayer.dispose();
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
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
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
                    widget.podcast.imageUrl,
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
                    widget.podcast.title,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.podcast.categoryName != null)
                  Text(
                    widget.podcast.categoryName!,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
        _buildPlayerControls(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.podcast.imageUrl,
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
                  widget.podcast.title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 28),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.podcast.categoryName != null)
                  Text(
                    widget.podcast.categoryName!,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  widget.podcast.description,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 32),
                _buildPlayerControls(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls() {
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
              Text(_formatDuration(_position)),
              Text(_formatDuration(_duration)),
            ],
          ),
          Slider(
            value: _position.inSeconds.toDouble(),
            min: 0,
            max: _duration.inSeconds.toDouble() > 0
                ? _duration.inSeconds.toDouble()
                : 1,
            onChanged: (value) {
              final position = Duration(seconds: value.toInt());
              _audioPlayer.seek(position);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: ResponsiveHelper.isMobile(context) ? 32 : 40,
                onPressed: () {
                  _audioPlayer.seek(
                    Duration(seconds: _position.inSeconds - 10),
                  );
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(_isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled),
                iconSize: ResponsiveHelper.isMobile(context) ? 64 : 80,
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  if (_isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play();
                  }
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_30),
                iconSize: ResponsiveHelper.isMobile(context) ? 32 : 40,
                onPressed: () {
                  _audioPlayer.seek(
                    Duration(seconds: _position.inSeconds + 30),
                  );
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
                value: _playbackSpeed,
                items: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
                    .map((speed) => DropdownMenuItem(
                          value: speed,
                          child: Text('${speed}x'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _playbackSpeed = value;
                    });
                    _audioPlayer.setSpeed(value);
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
