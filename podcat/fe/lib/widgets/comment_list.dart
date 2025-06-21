import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcat/blocs/auth/auth_bloc.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podcat/core/utils/responsive_helper.dart';

class CommentList extends StatelessWidget {
  final String podcastId;

  const CommentList({super.key, required this.podcastId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PodcastBloc, PodcastState>(
      builder: (context, state) {
        final comments = state.comments;

        if (comments == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (comments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(l10n.noCommentsYet),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          //physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            final isCurrentUser =
                context.read<AuthBloc>().state.user?.id == comment.userId;

            return ListTile(
              leading: CircleAvatar(
                child: Text((comment.userId.isNotEmpty
                        ? comment.userId.substring(0, 1)
                        : "?")
                    .toUpperCase()),
              ),
              title: Row(
                children: [
                  Text(
                    comment.userId.isNotEmpty
                        ? '${comment.userId.substring(0, min(5, comment.userId.length))}'
                        : 'Unknown User',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.you,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(context, comment.createdAt),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 12),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: isCurrentUser
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        context.read<PodcastBloc>().add(
                              DeleteComment(
                                podcastId: podcastId,
                                commentId: comment.id,
                              ),
                            );
                      },
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? l10n.dayAgo : l10n.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? l10n.hourAgo : l10n.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? l10n.minuteAgo : l10n.minutesAgo}';
    } else {
      return l10n.justNow;
    }
  }
}
