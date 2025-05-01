import 'package:flutter/material.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveHelper.isMobile(context) ? 120.0 : 150.0;
    final iconSize = ResponsiveHelper.isMobile(context) ? 40.0 : 50.0;
    final imageSize = ResponsiveHelper.isMobile(context) ? 80.0 : 100.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(imageSize / 2),
              ),
              child: category.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(imageSize / 2),
                      child: Image.network(
                        category.imageUrl!,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.category,
                            size: iconSize,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.category,
                      size: iconSize,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getFontSize(context, 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
