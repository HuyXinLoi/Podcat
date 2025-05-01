part of 'podcast_bloc.dart';

abstract class PodcastEvent extends Equatable {
  const PodcastEvent();

  @override
  List<Object> get props => [];
}

class LoadPodcasts extends PodcastEvent {
  final int page;
  final int size;

  const LoadPodcasts({this.page = 0, this.size = 20});

  @override
  List<Object> get props => [page, size];
}

class LoadPodcastById extends PodcastEvent {
  final String id;

  const LoadPodcastById({required this.id});

  @override
  List<Object> get props => [id];
}

class SearchPodcasts extends PodcastEvent {
  final String keyword;
  final int page;
  final int size;

  const SearchPodcasts({
    required this.keyword,
    this.page = 0,
    this.size = 20,
  });

  @override
  List<Object> get props => [keyword, page, size];
}

class LoadPodcastsByCategory extends PodcastEvent {
  final String categoryId;
  final int page;
  final int size;

  const LoadPodcastsByCategory({
    required this.categoryId,
    this.page = 0,
    this.size = 20,
  });

  @override
  List<Object> get props => [categoryId, page, size];
}

class CreatePodcast extends PodcastEvent {
  final Map<String, dynamic> podcastData;

  const CreatePodcast({required this.podcastData});

  @override
  List<Object> get props => [podcastData];
}

class DeletePodcast extends PodcastEvent {
  final String id;

  const DeletePodcast({required this.id});

  @override
  List<Object> get props => [id];
}

class LoadComments extends PodcastEvent {
  final String podcastId;

  const LoadComments({required this.podcastId});

  @override
  List<Object> get props => [podcastId];
}

class AddComment extends PodcastEvent {
  final String podcastId;
  final String content;

  const AddComment({
    required this.podcastId,
    required this.content,
  });

  @override
  List<Object> get props => [podcastId, content];
}

class DeleteComment extends PodcastEvent {
  final String podcastId;
  final String commentId;

  const DeleteComment({
    required this.podcastId,
    required this.commentId,
  });

  @override
  List<Object> get props => [podcastId, commentId];
}

class SaveProgress extends PodcastEvent {
  final String podcastId;
  final int progress;

  const SaveProgress({
    required this.podcastId,
    required this.progress,
  });

  @override
  List<Object> get props => [podcastId, progress];
}
