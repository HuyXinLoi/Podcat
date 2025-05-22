import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/generated/app_localizations.dart';
import 'package:podcat/models/playlist.dart';
import 'package:podcat/models/podcast.dart';
import 'package:podcat/views/podcast/podcast_detail_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final Map<String, Podcast> _podcasts = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPodcasts();
  }

  Future<void> _loadPodcasts() async {
    setState(() {
      _isLoading = true;
    });

    for (final podcastId in widget.playlist.podcastIds) {
      if (!_podcasts.containsKey(podcastId)) {
        try {
          final podcastBloc = context.read<PodcastBloc>();
          podcastBloc.add(LoadPodcastById(id: podcastId));

          // Wait for the podcast to load
          await Future.delayed(const Duration(milliseconds: 500));

          final state = podcastBloc.state;
          if (state.currentPodcast != null &&
              state.currentPodcast!.id == podcastId) {
            setState(() {
              _podcasts[podcastId] = state.currentPodcast!;
            });
          }
        } catch (e) {
          print('Error loading podcast $podcastId: $e');
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
      ),
      body: _isLoading && _podcasts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildPodcastList(),
    );
  }

  Widget _buildPodcastList() {
    final l10n = AppLocalizations.of(context);
    if (widget.playlist.podcastIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_play,
              size: ResponsiveHelper.getFontSize(context, 70),
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              // context.tr('empty_playlist'),
              l10n.emptyPlaylist,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 18),
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // context.tr('add_podcasts_to_playlist'),
              l10n.addPodcastsToPlaylist,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 14),
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: ResponsiveHelper.getPadding(context),
      itemCount: widget.playlist.podcastIds.length,
      itemBuilder: (context, index) {
        final podcastId = widget.playlist.podcastIds.elementAt(index);
        final podcast = _podcasts[podcastId];

        if (podcast == null) {
          return ListTile(
            leading: Container(
              width: ResponsiveHelper.isMobile(context) ? 56 : 70,
              height: ResponsiveHelper.isMobile(context) ? 56 : 70,
              color: Colors.grey[300],
              child: const Icon(Icons.headphones),
            ),
            title: const Text('Loading...'),
            subtitle: const LinearProgressIndicator(),
          );
        }

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              podcast.imageUrl,
              width: ResponsiveHelper.isMobile(context) ? 56 : 70,
              height: ResponsiveHelper.isMobile(context) ? 56 : 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: ResponsiveHelper.isMobile(context) ? 56 : 70,
                  height: ResponsiveHelper.isMobile(context) ? 56 : 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.headphones),
                );
              },
            ),
          ),
          title: Text(
            podcast.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            podcast.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
            ),
          ),
          trailing: Text(
            podcast.durationFormatted,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PodcastDetailScreen(podcastId: podcast.id),
              ),
            );
          },
        );
      },
    );
  }
}
