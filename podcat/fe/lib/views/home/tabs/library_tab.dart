import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/favorite/favorite_bloc.dart';
import 'package:podcat/blocs/playlist/playlist_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/views/playlist/playlist_detail_screen.dart';
import 'package:podcat/views/playlist/playlist_form_screen.dart';
import 'package:podcat/views/podcast/podcast_detail_screen.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    context.read<FavoriteBloc>().add(const LoadFavorites());
    context.read<PlaylistBloc>().add(LoadPlaylists());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.library,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: l10n.favorites),
            Tab(text: l10n.playlists),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesTab(),
          _buildPlaylistsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => const PlaylistFormScreen(),
                //   ),
                // );
                context.pushNamed('playlist-create');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFavoritesTab() {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FavoriteBloc>().add(const LoadFavorites());
      },
      child: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state.status == FavoriteStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == FavoriteStatus.error) {
            return Center(child: Text('Error: ${state.error}'));
          }

          final favorites = state.favorites;
          if (favorites == null || favorites.content.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: ResponsiveHelper.getFontSize(context, 70),
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noFavoritesYet,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.likePodcastsHint,
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
            itemCount: favorites.content.length,
            itemBuilder: (context, index) {
              final podcast = favorites.content[index];
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
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    context
                        .read<FavoriteBloc>()
                        .add(ToggleFavorite(podcastId: podcast.id));
                  },
                ),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) =>
                  //         PodcastDetailScreen(podcastId: podcast.id),
                  //   ),
                  // );
                  context.push('/podcast/${podcast.id}');
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PlaylistBloc>().add(LoadPlaylists());
      },
      child: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state.status == PlaylistStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PlaylistStatus.error) {
            return Center(child: Text('Error: ${state.error}'));
          }

          final playlists = state.playlists;
          if (playlists == null || playlists.isEmpty) {
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
                    l10n.noPlaylistsYet,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.createPlaylistHint,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const PlaylistFormScreen(),
                      //   ),
                      // );
                      context.pushNamed('playlist-create');
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createPlaylist),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: ResponsiveHelper.getPadding(context),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: Container(
                  width: ResponsiveHelper.isMobile(context) ? 56 : 70,
                  height: ResponsiveHelper.isMobile(context) ? 56 : 70,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.playlist_play,
                    color: Colors.white,
                    size: ResponsiveHelper.isMobile(context) ? 32 : 40,
                  ),
                ),
                title: Text(
                  playlist.name,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${playlist.podcastIds.length} ${l10n.podcasts}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                  ),
                ),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => PlaylistDetailScreen(playlist: playlist),
                  //   ),
                  // );
                  context.pushNamed(
                    'playlist-detail',
                    pathParameters: {'id': playlist.id},
                    extra: playlist,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
