import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:podcat/core/utils/app_localizations.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/models/category.dart';
import 'package:podcat/repositories/podcast_repository.dart';
import 'package:podcat/views/podcast/podcast_detail_screen.dart';

class CategoryPodcastsScreen extends StatefulWidget {
  final Category category;

  const CategoryPodcastsScreen({super.key, required this.category});

  @override
  State<CategoryPodcastsScreen> createState() => _CategoryPodcastsScreenState();
}

class _CategoryPodcastsScreenState extends State<CategoryPodcastsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPodcasts();
  }

  void _loadPodcasts() {
    // Create a new PodcastBloc specifically for this screen
    final podcastRepository = RepositoryProvider.of<PodcastRepository>(context);
    final podcastBloc = PodcastBloc(podcastRepository: podcastRepository);

    // Add the event to load podcasts by category
    podcastBloc.add(LoadPodcastsByCategory(categoryId: widget.category.id));

    // Replace the existing BlocProvider with a new one
    BlocProvider.of<PodcastBloc>(context).add(
      LoadPodcastsByCategory(categoryId: widget.category.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (context, state) {
          if (state.status == PodcastStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PodcastStatus.error) {
            return Center(child: Text('Error: ${state.error}'));
          }

          final podcasts = state.podcasts?.content;
          if (podcasts == null || podcasts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.headphones,
                    size: ResponsiveHelper.getFontSize(context, 70),
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('noPodcastsInCategory'),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ResponsiveHelper.isDesktop(context)
              ? _buildGridView(podcasts)
              : _buildListView(podcasts);
        },
      ),
    );
  }

  Widget _buildListView(List podcasts) {
    return ListView.builder(
      padding: ResponsiveHelper.getPadding(context),
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
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
                builder: (_) => PodcastDetailScreen(podcastId: podcast.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGridView(List podcasts) {
    return GridView.builder(
      padding: ResponsiveHelper.getPadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PodcastDetailScreen(podcastId: podcast.id),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    podcast.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.headphones,
                          size: 50,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                podcast.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                podcast.durationFormatted,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 12),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
