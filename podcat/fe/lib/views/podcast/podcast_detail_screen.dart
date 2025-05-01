import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcat/blocs/favorite/favorite_bloc.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:podcat/core/utils/app_localizations.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/models/podcast.dart';
import 'package:podcat/views/podcast/podcast_player_screen.dart';
import 'package:podcat/widgets/add_to_playlist_dialog.dart';
import 'package:podcat/widgets/comment_list.dart';

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

  Future<void> _loadData() async {
    context.read<PodcastBloc>().add(LoadPodcastById(id: widget.podcastId));
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
      builder: (context) => AddToPlaylistDialog(
        podcastId: widget.podcastId,
      ),
    );
  }

  void _addComment() {
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      context.read<PodcastBloc>().add(
            AddComment(
              podcastId: widget.podcastId,
              content: comment,
            ),
          );
      _commentController.clear();
    }
  }

  void _playPodcast(Podcast podcast) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PodcastPlayerScreen(podcast: podcast),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      body: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (context, state) {
          if (state.status == PodcastStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PodcastStatus.error) {
            return Center(child: Text('Error: ${state.error}'));
          }

          final podcast = state.currentPodcast;
          if (podcast == null) {
            return Center(child: Text(context.tr('podcast_not_found')));
          }

          if (isDesktop) {
            return _buildDesktopLayout(podcast);
          } else {
            return _buildMobileLayout(podcast);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(Podcast podcast) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(podcast),
        SliverToBoxAdapter(
          child: Padding(
            padding: ResponsiveHelper.getPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPodcastInfo(podcast),
                const SizedBox(height: 16),
                _buildActionButtons(podcast),
                const SizedBox(height: 24),
                _buildDescription(podcast),
                const SizedBox(height: 24),
                _buildCommentSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(Podcast podcast) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(podcast),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPodcastInfo(podcast),
                      const SizedBox(height: 24),
                      _buildActionButtons(podcast),
                      const SizedBox(height: 32),
                      _buildDescription(podcast),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('comments'),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 20),
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
                          hintText: context.tr('add_comment'),
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
                Expanded(
                  child: CommentList(podcastId: podcast.id),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(Podcast podcast) {
    return SliverAppBar(
      expandedHeight: ResponsiveHelper.isMobile(context) ? 240 : 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          podcast.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Icon(
                Icons.headphones,
                size: ResponsiveHelper.isMobile(context) ? 80 : 120,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPodcastInfo(Podcast podcast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          podcast.title,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (podcast.categoryName != null) ...[
              Chip(
                label: Text(podcast.categoryName!),
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.headphones,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '${podcast.viewCount} ${context.tr('listens')}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.favorite,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '${podcast.likeCount} ${context.tr('likes')}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${context.tr('duration')}: ${podcast.durationFormatted}',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Podcast podcast) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _playPodcast(podcast),
          icon: const Icon(Icons.play_arrow),
          label: Text(context.tr('play')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.isMobile(context) ? 16 : 24,
              vertical: ResponsiveHelper.isMobile(context) ? 12 : 16,
            ),
          ),
        ),
        BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, state) {
            final isFavorite = state.isFavorite(widget.podcastId);
            return IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
                size: ResponsiveHelper.isMobile(context) ? 24 : 28,
              ),
            );
          },
        ),
        IconButton(
          onPressed: _showAddToPlaylistDialog,
          icon: Icon(
            Icons.playlist_add,
            size: ResponsiveHelper.isMobile(context) ? 24 : 28,
          ),
        ),
        IconButton(
          onPressed: () {
            // Share podcast
          },
          icon: Icon(
            Icons.share,
            size: ResponsiveHelper.isMobile(context) ? 24 : 28,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(Podcast podcast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('description'),
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          podcast.description,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 16),
          ),
        ),
        if (podcast.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: podcast.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.grey[200],
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentSection() {
    if (ResponsiveHelper.isDesktop(context)) {
      return const SizedBox
          .shrink(); // Comments are in the right panel for desktop
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('comments'),
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
                  hintText: context.tr('add_comment'),
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
        CommentList(podcastId: widget.podcastId),
      ],
    );
  }
}
