import 'package:flutter/material.dart';
import 'package:podcat/models/podcast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CurrentPlaylistDialog extends StatelessWidget {
  final List<Podcast> playlist;
  final int currentIndex;
  final Function(Podcast podcast, int index) onPlayTrack;

  const CurrentPlaylistDialog({
    super.key,
    required this.playlist,
    required this.currentIndex,
    required this.onPlayTrack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text('DSP Playlist'),
      content: SizedBox(
        width: double.maxFinite,
        child: playlist.isEmpty
            ? Center(child: Text('Empty Playlish'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: playlist.length,
                itemBuilder: (context, index) {
                  final podcast = playlist[index];
                  final bool isCurrent = index == currentIndex;
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
                    subtitle: Text(podcast.categoryName ?? '',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => onPlayTrack(podcast, index),
                    selected: isCurrent,
                    selectedTileColor: isCurrent
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : null,
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
