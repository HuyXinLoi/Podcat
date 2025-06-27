import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:podcat/models/podcast.dart';
import 'package:podcat/widgets/comment_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommentBottomSheet extends StatefulWidget {
  final Podcast podcast;

  const CommentBottomSheet({super.key, required this.podcast});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _addComment() {
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      context.read<PodcastBloc>().add(AddComment(
            podcastId: widget.podcast.id,
            content: comment,
          ));
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.comments,
              style: Theme.of(context).textTheme.titleLarge,
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
                    maxLines: null,
                    minLines: 1,
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
              child: CommentList(podcastId: widget.podcast.id),
            ),
          ],
        ),
      ),
    );
  }
}
