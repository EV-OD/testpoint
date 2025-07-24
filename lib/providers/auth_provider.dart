import 'package:flutter/material.dart';
import 'package:testpoint/core/services/auth_service.dart';
import 'package:testpoint/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._authService) {
    _checkCurrentUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> _checkCurrentUser() async {
    print('AuthProvider: Checking current user...');
    _isLoading = true;
    notifyListeners();
    _currentUser = await _authService.getCurrentUser();
    _isLoading = false;
    print('AuthProvider: Current user check complete. isAuthenticated: $isAuthenticated');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.logout();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
