import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/services/auth_service.dart';
import '../../../models/user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  User? _user;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Login method - Updated to use email instead of username
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call AuthService
      final result = await _authService.login(
        email: email,
        password: password,
      );

      print('🔑 Login Result: $result');

      if (result['success'] == true) {
        // Successful login
        if (result['user'] != null) {
          _user = result['user'] as User;
          _isLoggedIn = true;
          
          print('✅ Login successful! User: ${_user?.fullName}');
          
          // Save user data to local storage
          await _saveUserData(_user!);
        }
        
        // Store token if needed
        // final token = result['token'];
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Failed login
        _errorMessage = result['message'] ?? 'Đăng nhập thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Signup method
  Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String dateOfBirth,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call AuthService
      final result = await _authService.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        dateOfBirth: dateOfBirth,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (result['success'] == true) {
        // Successful signup
        if (result['user'] != null) {
          _user = result['user'] as User;
          _isLoggedIn = true;
          
          print('✅ Signup successful! User: ${_user?.fullName}');
          
          // Save user data to local storage
          await _saveUserData(_user!);
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Failed signup
        _errorMessage = result['message'] ?? 'Đăng ký thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call AuthService to logout
      final result = await _authService.logout();

      if (result['success'] == true) {
        // Successful logout
        await _clearUserData();
        _user = null;
        _isLoggedIn = false;
        _errorMessage = null;
        
        print('✅ Logout successful!');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Failed logout - still clear local data for safety
        await _clearUserData();
        _user = null;
        _isLoggedIn = false;
        _errorMessage = result['message'] ?? 'Đăng xuất thất bại';
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Logout error: $e');
      
      // Clear local data even if API call fails
      await _clearUserData();
      _user = null;
      _isLoggedIn = false;
      _errorMessage = 'Có lỗi xảy ra khi đăng xuất';
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Save user data to local storage
  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      await prefs.setBool('is_logged_in', true);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Load user data from local storage
  Future<User?> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (userData != null && isLoggedIn) {
        return User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
    return null;
  }

  // Clear user data from local storage
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.setBool('is_logged_in', false);
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // Check if user is already logged in (for app startup)
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load stored user data
      final storedUser = await _loadUserData();
      
      if (storedUser != null) {
        _user = storedUser;
        _isLoggedIn = true;
      } else {
        _isLoggedIn = false;
        _user = null;
      }
      
    } catch (e) {
      _errorMessage = 'Lỗi kiểm tra trạng thái đăng nhập';
      _isLoggedIn = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (email.isEmpty) {
        throw Exception('Vui lòng nhập email');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Email không hợp lệ');
      }

      // Mock successful password reset
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}