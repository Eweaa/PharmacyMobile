import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _userRole = '';
  String _userEmail = '';
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  String get userRole => _userRole;
  String get userEmail => _userEmail;

  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isLoggedIn = _prefs?.getBool('is_logged_in') ?? false;
      _userRole = _prefs?.getString('user_role') ?? '';
      _userEmail = _prefs?.getString('user_email') ?? '';
      
      // Check if token is expired
      if (_isLoggedIn) {
        final tokenExpirationString = _prefs?.getString('token_expiration');
        if (tokenExpirationString != null) {
          final expirationDate = DateTime.parse(tokenExpirationString);
          if (DateTime.now().isAfter(expirationDate)) {
            // Token is expired, log out
            await logout();
          }
        }
      }
      
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> login(String email, {String? token, int? expiresIn}) async {
    // Store the user's email
    _userEmail = email;
    
    // Store the token and expiration if provided
    if (token != null && _prefs != null) {
      await _prefs!.setString('access_token', token);
    }
    
    if (expiresIn != null && _prefs != null) {
      // Calculate expiration date
      final expirationDate = DateTime.now().add(Duration(seconds: expiresIn));
      await _prefs!.setString('token_expiration', expirationDate.toIso8601String());
    }
    
    // Determine user role based on email (or other logic)
    if (email.contains('admin')) {
      _userRole = 'admin';
    } else {
      _userRole = 'user';
    }
    
    _isLoggedIn = true;
    
    // Save login state
    if (_prefs != null) {
      await _prefs!.setBool('is_logged_in', true);
      await _prefs!.setString('user_email', email);
      await _prefs!.setString('user_role', _userRole);
    }
    
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userRole = '';
    _userEmail = '';
    await _prefs?.clear();
    notifyListeners();
  }

  // Add this getter to retrieve token expiration
  Future<String> get tokenExpiration async {
    if (_prefs == null) {
      await init();
    }
    return _prefs?.getString('token_expiration') ?? 'No expiration found';
  }

  // Add this method to check if token is expired
  Future<bool> isTokenExpired() async {
    if (_prefs == null) {
      await init();
    }
    
    final tokenExpirationString = _prefs?.getString('token_expiration');
    if (tokenExpirationString == null) {
      return true; // No expiration date means token is considered expired
    }
    
    final expirationDate = DateTime.parse(tokenExpirationString);
    return DateTime.now().isAfter(expirationDate);
  }
  
  // Format the token expiration for display
  Future<String> get formattedTokenExpiration async {
    final expiration = await tokenExpiration;
    if (expiration == 'No expiration found') {
      return expiration;
    }
    
    try {
      final expirationDate = DateTime.parse(expiration);
      final now = DateTime.now();
      
      if (now.isAfter(expirationDate)) {
        return 'Expired';
      }
      
      final difference = expirationDate.difference(now);
      if (difference.inDays > 0) {
        return '${difference.inDays} days, ${difference.inHours % 24} hours remaining';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours, ${difference.inMinutes % 60} minutes remaining';
      } else {
        return '${difference.inMinutes} minutes remaining';
      }
    } catch (e) {
      return 'Invalid date format';
    }
  }
  
  // Add this method to get the access token
  Future<String> getAccessToken() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs?.getString('access_token') ?? '';
  }
}