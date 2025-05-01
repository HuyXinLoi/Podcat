import 'package:flutter/material.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/models/podcast.dart';

class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  final VoidCallback onTap;

  const PodcastCard({
    super.key,
    required this.podcast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveHelper.getCardWidth(context);
    final cardHeight = ResponsiveHelper.getCardHeight(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                podcast.imageUrl,
                width: cardWidth,
                height: cardWidth,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: cardWidth,
                    height: cardWidth,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.headphones,
                      size: cardWidth * 0.4,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              podcast.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getFontSize(context, 14),
              ),
            ),
            const SizedBox(height: 4),
            if (podcast.categoryName != null)
              Text(
                podcast.categoryName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: ResponsiveHelper.getFontSize(context, 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
