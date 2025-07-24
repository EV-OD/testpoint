import 'package:flutter/material.dart';
import 'package:testpoint/core/services/auth_service.dart';
import 'package:testpoint/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  bool _isInitialAuthCheckLoading = false; // For initial app startup check
  bool _isLoginLoading = false; // For login/logout actions

  AuthProvider(this._authService) {
    _checkCurrentUser();
  }

  User? get currentUser => _currentUser;
  bool get isInitialAuthCheckLoading => _isInitialAuthCheckLoading;
  bool get isLoginLoading => _isLoginLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> _checkCurrentUser() async {
    _isInitialAuthCheckLoading = true;
    notifyListeners();
    _currentUser = await _authService.getCurrentUser();
    _isInitialAuthCheckLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoginLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.login(email, password);
      _isLoginLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoginLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoginLoading = true; // Use login loading for logout as well for simplicity
    notifyListeners();
    await _authService.logout();
    _currentUser = null;
    _isLoginLoading = false;
    notifyListeners();
  }
}