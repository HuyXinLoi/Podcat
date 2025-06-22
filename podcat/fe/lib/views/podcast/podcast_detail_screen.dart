import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/audio_player/audio_player_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/widgets/comment_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/podcast/podcast_bloc.dart';
import '../../models/podcast.dart';
import '../../widgets/add_to_playlist_dialog.dart';

class PodcastDetailScreen extends StatefulWidget {
  final String podcastId;

  const PodcastDetailScreen({super.key, required this.podcastId});

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadData() {
    final bloc = context.read<PodcastBloc>();
    bloc.add(LoadPodcastById(id: widget.podcastId));
    context
        .read<FavoriteBloc>()
        .add(CheckFavoriteStatus(podcastId: widget.podcastId));
  }

  void _toggleFavorite() {
    context
        .read<FavoriteBloc>()
        .add(ToggleFavorite(podcastId: widget.podcastId));
  }

  void _showAddToPlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AddToPlaylistDialog(podcastId: widget.podcastId),
    );
  }

  void _addComment() {
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      context.read<PodcastBloc>().add(AddComment(
            podcastId: widget.podcastId,
            content: comment,
          ));
      _commentController.clear();
    }
  }

  void _playPodcast(Podcast podcast) {
    context.push('/podcast/${podcast.id}/play', extra: podcast);
    context.read<AudioPlayerBloc>().add(PlayPodcast(podcast: podcast));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<PodcastBloc, PodcastState>(
      listener: (context, state) {
        if (state.status == PodcastStatus.loaded &&
            state.currentPodcast != null) {
          context
              .read<FavoriteBloc>()
              .add(CheckFavoriteStatus(podcastId: widget.podcastId));
        }
      },
      builder: (context, state) {
        if (state.status == PodcastStatus.loading) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.loading)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == PodcastStatus.error) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.error)),
            body:
                Center(child: Text('Error: ${state.error ?? "Unknown error"}')),
          );
        }

        final podcast = state.currentPodcast;
        if (podcast == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.notFound)),
            body: Center(child: Text(l10n.podcastNotFound)),
          );
        }

        final isDesktop = ResponsiveHelper.isDesktop(context);
        return Scaffold(
          body: isDesktop
              ? _buildDesktopLayout(podcast)
              : _buildMobileLayout(podcast),
        );
      },
    );
  }

  Widget _buildMobileLayout(Podcast podcast) {
    return SingleChildScrollView(
        child: Column(
      children: [
        _buildAppBar(podcast),
        _buildPodcastInfo(podcast),
        _buildActionButtons(podcast),
        _buildDescription(podcast),
        _buildCommentSection(),
      ],
    ));
  }

  Widget _buildDesktopLayout(Podcast podcast) {
    return Row(
      children: [
        Expanded(child: _buildPodcastInfo(podcast)),
        Expanded(
          child: Column(
            children: [
              _buildActionButtons(podcast),
              _buildDescription(podcast),
              _buildCommentSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(Podcast podcast) {
    return AppBar(
      title: Text(podcast.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.playlist_add),
          onPressed: _showAddToPlaylistDialog,
        ),
      ],
    );
  }

  Widget _buildPodcastInfo(Podcast podcast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(podcast.imageUrl),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            podcast.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Podcast podcast) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _playPodcast(podcast),
          icon: const Icon(Icons.play_arrow, color: Colors.white),
          label: Text(l10n.play),
        ),
      ],
    );
  }

  Widget _buildDescription(Podcast podcast) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(podcast.description),
    );
  }

  Widget _buildCommentSection() {
    final l10n = AppLocalizations.of(context)!;
    if (ResponsiveHelper.isDesktop(context)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.comments,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: l10n.addComment,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addComment,
                icon: const Icon(Icons.send),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<PodcastBloc, PodcastState>(
            builder: (context, state) {
              if (state.comments == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state.comments!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(l10n.userProfileNotFound),
                  ),
                );
              }
              return CommentList(podcastId: widget.podcastId);
            },
          ),
        ],
      ),
    );
  }
}
