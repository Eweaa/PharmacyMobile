import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('ar'); // Default to Arabic
  SharedPreferences? _prefs;

  Locale get currentLocale => _currentLocale;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguage = _prefs!.getString('language');
    
    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
    } else {
      // If no saved language, set Arabic as default and save it
      await _prefs!.setString('language', 'ar');
    }
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    await _prefs!.setString('language', languageCode);
    notifyListeners();
  }
}