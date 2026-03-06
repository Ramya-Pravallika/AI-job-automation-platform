import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  User? user;
  bool isLoading = false;
  String? error;
  bool isAuthenticated = false;

  Future<void> initialize() async {
    isAuthenticated = await _authService.isLoggedIn();
    if (isAuthenticated) {
      try {
        user = await _authService.getMe();
      } catch (_) {
        isAuthenticated = false;
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      user = await _authService.getMe();
      isAuthenticated = true;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _authService.signup(email, password);
      user = await _authService.getMe();
      isAuthenticated = true;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(UserProfile profile) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _authService.saveProfile(profile, isUpdate: user?.profile != null);
      user = await _authService.getMe();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    isAuthenticated = false;
    notifyListeners();
  }
}
