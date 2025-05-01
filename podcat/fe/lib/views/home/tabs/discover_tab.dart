import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podcat/blocs/category/category_bloc.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/models/podcast.dart';
import 'package:podcat/views/category/category_podcasts_screen.dart';
import 'package:podcat/views/podcast/podcast_detail_screen.dart';
import 'package:podcat/widgets/category_card.dart';
import 'package:podcat/widgets/podcast_card.dart';

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discover),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PodcastBloc>().add(const LoadPodcasts());
          context.read<CategoryBloc>().add(LoadCategories());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: ResponsiveHelper.getPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoriesSection(context),
                SizedBox(height: ResponsiveHelper.isMobile(context) ? 20 : 32),
                _buildTrendingSection(context),
                SizedBox(height: ResponsiveHelper.isMobile(context) ? 20 : 32),
                _buildRecentSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.categories,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state.status == CategoryStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CategoryStatus.error) {
              return Center(child: Text('Error: ${state.error}'));
            }

            final categories = state.categories;
            if (categories == null || categories.isEmpty) {
              return Center(child: Text(l10n.noPodcastsFound));
            }

            return SizedBox(
              height: ResponsiveHelper.isMobile(context) ? 120 : 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryCard(
                    category: category,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoryPodcastsScreen(category: category),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.trendingNow,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<PodcastBloc, PodcastState>(
          builder: (context, state) {
            if (state.status == PodcastStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == PodcastStatus.error) {
              return Center(child: Text('Error: ${state.error}'));
            }

            final podcasts = state.podcasts?.content;
            if (podcasts == null || podcasts.isEmpty) {
              return Center(child: Text(l10n.noPodcastsFound));
            }

            // Sort by view count for trending
            final trendingPodcasts = List<Podcast>.from(podcasts)
              ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
            final displayPodcasts = trendingPodcasts.take(5).toList();

            return SizedBox(
              height: ResponsiveHelper.isMobile(context) ? 220 : 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayPodcasts.length,
                itemBuilder: (context, index) {
                  final podcast = displayPodcasts[index];
                  return PodcastCard(
                    podcast: podcast,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PodcastDetailScreen(podcastId: podcast.id),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentlyAdded,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<PodcastBloc, PodcastState>(
          builder: (context, state) {
            if (state.status == PodcastStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == PodcastStatus.error) {
              return Center(child: Text('Error: ${state.error}'));
            }

            final podcasts = state.podcasts?.content;
            if (podcasts == null || podcasts.isEmpty) {
              return Center(child: Text(l10n.noPodcastsFound));
            }

            // Sort by created date for recent
            final recentPodcasts = List<Podcast>.from(podcasts)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final displayPodcasts = recentPodcasts.take(5).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayPodcasts.length,
              itemBuilder: (context, index) {
                final podcast = displayPodcasts[index];
                return ListTile(
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
                  trailing: Text(
                    podcast.durationFormatted,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PodcastDetailScreen(podcastId: podcast.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
