import 'package:flutter/material.dart';

import '../core/services/category_service.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  bool _isLoading = false;
  String? _error;
  List<Category>? _categories;
  Category? _currentCategory;
  List<Category>? _searchResults;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Category>? get categories => _categories;
  Category? get currentCategory => _currentCategory;
  List<Category>? get searchResults => _searchResults;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategoryById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentCategory = await _categoryService.getCategoryById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCategories(String keyword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _categoryService.searchCategories(keyword);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
