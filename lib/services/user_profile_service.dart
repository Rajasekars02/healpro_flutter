import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService extends ChangeNotifier {
  static const _keyName = 'user_name';
  static const _keyAge = 'user_age';
  static const _keyGender = 'user_gender';
  static const _keyThemeMode = 'theme_mode';
  static const _keyServerUrl = 'server_url';

  String _name = '';
  int _age = 0;
  String _gender = 'Prefer not to say';
  ThemeMode _themeMode = ThemeMode.system;
  String _serverUrl = 'https://healpro-api.onrender.com/api';

  String get name => _name;
  int get age => _age;
  String get gender => _gender;
  ThemeMode get themeMode => _themeMode;
  String get serverUrl => _serverUrl;

  bool get hasProfile => _name.isNotEmpty && _age > 0;

  UserProfileService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_keyName) ?? '';
    _age = prefs.getInt(_keyAge) ?? 0;
    _gender = prefs.getString(_keyGender) ?? 'Prefer not to say';
    _serverUrl = prefs.getString(_keyServerUrl) ?? 'https://healpro-api.onrender.com/api';
    final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }

  Future<void> updateProfile({required String name, required int age, required String gender}) async {
    _name = name;
    _age = age;
    _gender = gender;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setInt(_keyAge, age);
    await prefs.setString(_keyGender, gender);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }

  Future<void> setServerUrl(String url) async {
    _serverUrl = url.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerUrl, _serverUrl);
    notifyListeners();
  }
}
