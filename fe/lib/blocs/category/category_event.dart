part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {}

class LoadCategoryById extends CategoryEvent {
  final String id;

  const LoadCategoryById({required this.id});

  @override
  List<Object> get props => [id];
}

class SearchCategories extends CategoryEvent {
  final String keyword;

  const SearchCategories({required this.keyword});

  @override
  List<Object> get props => [keyword];
}
