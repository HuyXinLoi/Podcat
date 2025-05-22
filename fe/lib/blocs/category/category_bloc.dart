import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:podcat/models/category.dart';
import 'package:podcat/repositories/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc({required this.categoryRepository})
      : super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadCategoryById>(_onLoadCategoryById);
    on<SearchCategories>(_onSearchCategories);
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final categories = await categoryRepository.getCategories();
      emit(state.copyWith(
        status: CategoryStatus.loaded,
        categories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadCategoryById(
      LoadCategoryById event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final category = await categoryRepository.getCategoryById(event.id);
      emit(state.copyWith(
        status: CategoryStatus.loaded,
        currentCategory: category,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSearchCategories(
      SearchCategories event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final searchResults =
          await categoryRepository.searchCategories(event.keyword);
      emit(state.copyWith(
        status: CategoryStatus.loaded,
        searchResults: searchResults,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        error: e.toString(),
      ));
    }
  }
}
