import 'package:flutter/material.dart';
import 'package:podcat/models/podcast.dart';

class CurrentPlaylistBottomSheet extends StatelessWidget {
  final List<Podcast> playlist;
  final int currentIndex;
  final Function(Podcast podcast, int index) onPlayTrack;

  const CurrentPlaylistBottomSheet({
    super.key,
    required this.playlist,
    required this.currentIndex,
    required this.onPlayTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            'DSP Playlist',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (playlist.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: Text('Empty Playlist')),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlist.length,
                itemBuilder: (context, index) {
                  final podcast = playlist[index];
                  final isCurrent = index == currentIndex;
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        podcast.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) =>
                            const Icon(Icons.music_note, size: 40),
                      ),
                    ),
                    title: Text(
                      podcast.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      podcast.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onPlayTrack(podcast, index),
                    selected: isCurrent,
                    selectedTileColor: Theme.of(context).colorScheme.primary,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
