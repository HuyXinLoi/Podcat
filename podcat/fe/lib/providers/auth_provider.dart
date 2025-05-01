import 'package:flutter/material.dart';
import 'package:podcat/core/services/auth_service.dart';
import 'package:podcat/core/services/user_service.dart';
import 'package:podcat/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _user;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  String? get error => _error;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        await _loadUserProfile();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.login(username, password);
      if (success) {
        _isLoggedIn = true;
        await _loadUserProfile();
      } else {
        _error = 'Invalid username or password';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.register(username, password);
      if (success) {
        _isLoggedIn = true;
        await _loadUserProfile();
      } else {
        _error = 'Registration failed';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _isLoggedIn = false;
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      _user = await _userService.getUserProfile();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userService.updateUserProfile(profileData);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
