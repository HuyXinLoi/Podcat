import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/playlist/playlist_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/views/playlist/playlist_form_screen.dart';

class AddToPlaylistDialog extends StatelessWidget {
  final String podcastId;

  const AddToPlaylistDialog({super.key, required this.podcastId});

  @override
  Widget build(BuildContext context) {
    // Load playlists if not already loaded
    final l10n = AppLocalizations.of(context)!;
    final playlistState = context.read<PlaylistBloc>().state;
    if (playlistState.playlists == null) {
      context.read<PlaylistBloc>().add(LoadPlaylists());
    }

    return Dialog(
      child: Container(
        width: ResponsiveHelper.isDesktop(context) ? 500 : double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.addToPlaylist,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<PlaylistBloc, PlaylistState>(
              builder: (context, state) {
                if (state.status == PlaylistStatus.loading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final playlists = state.playlists;
                if (playlists == null || playlists.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(l10n.noPlaylistsFound),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigator.pop(context);
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => const PlaylistFormScreen(),
                              //   ),
                              // );
                              context.pop();
                              context.push('/playlist/create');
                            },
                            child: Text(l10n.createPlaylist),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      final isInPlaylist =
                          playlist.podcastIds.contains(podcastId);

                      return ListTile(
                        title: Text(
                          playlist.name,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 16),
                          ),
                        ),
                        subtitle: Text(
                          '${playlist.podcastIds.length} ${l10n.podcasts}',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 14),
                          ),
                        ),
                        trailing: isInPlaylist
                            ? Icon(
                                Icons.check,
                                color: Colors.green,
                                size: ResponsiveHelper.getFontSize(context, 24),
                              )
                            : null,
                        onTap: () async {
                          if (!isInPlaylist) {
                            context.read<PlaylistBloc>().add(
                                  AddPodcastToPlaylist(
                                    playlistId: playlist.id,
                                    podcastId: podcastId,
                                  ),
                                );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${l10n.addedTo} ${playlist.name}'),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.pop(context);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => const PlaylistFormScreen(),
                    //   ),
                    // );
                    context.pop();
                    context.push('/playlist/create');
                  },
                  child: Text(l10n.newPlaylist),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
