part of 'category_bloc.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<Category>? categories;
  final Category? currentCategory;
  final List<Category>? searchResults;
  final String? error;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories,
    this.currentCategory,
    this.searchResults,
    this.error,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? categories,
    Category? currentCategory,
    List<Category>? searchResults,
    String? error,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      currentCategory: currentCategory ?? this.currentCategory,
      searchResults: searchResults ?? this.searchResults,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        currentCategory,
        searchResults,
        error,
      ];
}
