import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:podcat/models/comment.dart';
import 'package:podcat/models/page_response.dart';
import 'package:podcat/models/podcast.dart';
import 'package:podcat/repositories/podcast_repository.dart';

part 'podcast_event.dart';
part 'podcast_state.dart';

class PodcastBloc extends Bloc<PodcastEvent, PodcastState> {
  final PodcastRepository podcastRepository;

  PodcastBloc({required this.podcastRepository}) : super(const PodcastState()) {
    on<LoadPodcasts>(_onLoadPodcasts);
    on<LoadPodcastById>(_onLoadPodcastById);
    on<SearchPodcasts>(_onSearchPodcasts);
    on<LoadPodcastsByCategory>(_onLoadPodcastsByCategory);
    on<CreatePodcast>(_onCreatePodcast);
    on<DeletePodcast>(_onDeletePodcast);
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
    on<DeleteComment>(_onDeleteComment);
    on<SaveProgress>(_onSaveProgress);
  }

  Future<void> _onLoadPodcasts(
      LoadPodcasts event, Emitter<PodcastState> emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      final podcasts = await podcastRepository.getPodcasts(
        page: event.page,
        size: event.size,
      );
      emit(state.copyWith(
        status: PodcastStatus.loaded,
        podcasts: podcasts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PodcastStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadPodcastById(
      LoadPodcastById event, Emitter<PodcastState> emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      final podcast = await podcastRepository.getPodcastById(event.id);
      emit(state.copyWith(
        status: PodcastStatus.loaded,
        currentPodcast: podcast,
        comments: [], // Initialize with empty list to avoid null
      ));
      add(LoadComments(podcastId: event.id));
    } catch (e) {
      emit(state.copyWith(
        status: PodcastStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSearchPodcasts(
      SearchPodcasts event, Emitter<PodcastState> emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      final searchResults = await podcastRepository.searchPodcasts(
        event.keyword,
        page: event.page,
        size: event.size,
      );
      emit(state.copyWith(
        status: PodcastStatus.loaded,
        searchResults: searchResults,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PodcastStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadPodcastsByCategory(
      LoadPodcastsByCategory event, Emitter<PodcastState> emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      final podcasts = await podcastRepository.getPodcastsByCategory(
        event.categoryId,
        page: event.page,
        size: event.size,
      );
      emit(state.copyWith(
        status: PodcastStatus.loaded,
        podcasts: podcasts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PodcastStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCreatePodcast(
      CreatePodcast event, Emitter<PodcastState> emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      final podcast = await podcastRepository.createPodcast(event.podcastData);

      // Update podcasts list if it exists
      if (state.podcasts != null) {
        final updatedContent = [podcast, ...state.podcasts!.content];
        final updatedPodcasts = state.podcasts!.copyWith(
          content: updatedContent,
          totalElements: state.podcasts!.totalElements + 1,
        );

        emit(state.copyWith(
          status: PodcastStatus.loaded,
          podcasts: updatedPodcasts,
        ));
      } else {
        emit(state.copyWith(
          status: PodcastStatus.loaded,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PodcastStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeletePodcast(
      DeletePodcast event, Emitter<PodcastState> emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      await podcastRepository.deletePodcast(event.id);

      // Update podcasts list if it exists
      if (state.podcasts != null) {
        final updatedContent = state.podcasts!.content
            .where((podcast) => podcast.id != event.id)
            .toList();
        final updatedPodcasts = state.podcasts!.copyWith(
          content: updatedContent,
          totalElements: state.podcasts!.totalElements - 1,
        );

        emit(state.copyWith(
          status: PodcastStatus.loaded,
          podcasts: updatedPodcasts,
        ));
      } else {
        emit(state.copyWith(
          status: PodcastStatus.loaded,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PodcastStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadComments(
      LoadComments event, Emitter<PodcastState> emit) async {
    try {
      final comments = await podcastRepository.getComments(event.podcastId);
      emit(state.copyWith(
        comments: comments,
      ));
    } catch (e) {
      // Don't overwrite the comments if there's an error
      emit(state.copyWith(
        error: e.toString(),
        comments:
            state.comments ?? [], // Keep existing comments or use empty list
      ));
    }
  }

  Future<void> _onAddComment(
      AddComment event, Emitter<PodcastState> emit) async {
    try {
      final comment = await podcastRepository.addComment(
        event.podcastId,
        event.content,
      );

      final updatedComments = [
        comment,
        ...state.comments ?? [],
      ];

      emit(state.copyWith(
        comments: List<Comment>.from(updatedComments),
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteComment(
      DeleteComment event, Emitter<PodcastState> emit) async {
    try {
      await podcastRepository.deleteComment(
        event.podcastId,
        event.commentId,
      );

      if (state.comments != null) {
        final updatedComments = state.comments!
            .where((comment) => comment.id != event.commentId)
            .toList();

        emit(state.copyWith(
          comments: updatedComments,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSaveProgress(
      SaveProgress event, Emitter<PodcastState> emit) async {
    try {
      await podcastRepository.saveProgress(
        event.podcastId,
        event.progress,
      );
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
      ));
    }
  }
}
