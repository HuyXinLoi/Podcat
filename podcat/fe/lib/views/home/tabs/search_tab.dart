import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/views/podcast/podcast_detail_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<PodcastBloc>().add(SearchPodcasts(keyword: query));
      setState(() {
        _hasSearched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.search),
      ),
      body: Column(
        children: [
          Padding(
            padding: ResponsiveHelper.getPadding(context),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchPodcasts,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _hasSearched = false;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Expanded(
            child: _hasSearched
                ? _buildSearchResults()
                : _buildSearchSuggestions(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PodcastBloc, PodcastState>(
      builder: (context, state) {
        if (state.status == PodcastStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == PodcastStatus.error) {
          return Center(child: Text('Error: ${state.error}'));
        }

        final searchResults = state.searchResults;
        if (searchResults == null || searchResults.content.isEmpty) {
          return Center(child: Text(l10n.noPodcastsFound));
        }

        return ListView.builder(
          padding: ResponsiveHelper.getPadding(context),
          itemCount: searchResults.content.length,
          itemBuilder: (context, index) {
            final podcast = searchResults.content[index];
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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (podcast.categoryName != null)
                    Text(
                      podcast.categoryName!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: ResponsiveHelper.getFontSize(context, 12),
                      ),
                    ),
                  Text(
                    podcast.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                    ),
                  ),
                ],
              ),
              trailing: Text(
                podcast.durationFormatted,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                ),
              ),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => PodcastDetailScreen(podcastId: podcast.id),
                //   ),
                // );
                context.push(
                  '/podcast/${podcast.id}',
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: ResponsiveHelper.getFontSize(context, 70),
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchForPodcasts,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 18),
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.searchHint,
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
}
