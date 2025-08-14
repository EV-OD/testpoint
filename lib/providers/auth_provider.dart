import 'package:flutter/material.dart';
import 'package:testpoint/core/services/auth_service.dart';
import 'package:testpoint/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  bool _isInitialAuthCheckLoading = false; // For initial app startup check
  bool _isLoginLoading = false; // For login/logout actions
  String? _errorMessage; // New state variable for error messages

  AuthProvider(this._authService) {
    _checkCurrentUser();
  }

  User? get currentUser => _currentUser;
  bool get isInitialAuthCheckLoading => _isInitialAuthCheckLoading;
  bool get isLoginLoading => _isLoginLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage; // Getter for the new error message

  Future<void> _checkCurrentUser() async {
    _isInitialAuthCheckLoading = true;
    notifyListeners();
    _currentUser = await _authService.getCurrentUser();
    _isInitialAuthCheckLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoginLoading = true;
    _errorMessage = null; // Clear previous errors
    notifyListeners();
    try {
      _currentUser = await _authService.login(email, password);
      _isLoginLoading = false;
      if (_currentUser == null) {
        _errorMessage = 'Login failed. Please check your credentials.';
      }
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoginLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
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

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
