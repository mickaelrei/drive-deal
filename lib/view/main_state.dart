import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/user.dart';

/// Provider that holds information such as:
///
/// - App language
class MainState with ChangeNotifier {
  /// Constructor
  MainState() {
    unawaited(init());
  }

  User? _loggedUser;

  /// Current logged user
  User? get loggedUser => _loggedUser;

  String? _lastLogin;

  /// Last logged user info
  String? get lastLogin => _lastLogin;

  /// Current app language
  AppLanguage get appLanguage => loggedUser != null
      ? loggedUser!.settings.appLanguage
      : UserSettings.defaultAppLanguage;

  /// Current app theme
  AppTheme get appTheme => loggedUser != null
      ? loggedUser!.settings.appTheme
      : UserSettings.defaultAppTheme;

  /// Shared prefs to get/set user settings
  late final SharedPreferences _sharedPreferences;

  /// Initialize data
  Future<void> init() async {
    // Get shared prefs instance
    _sharedPreferences = await SharedPreferences.getInstance();

    // Update screen
    notifyListeners();
  }

  /// Set new app language
  Future<void> setAppLanguage(AppLanguage language) async {
    if (_loggedUser == null) {
      log('No logged user to set language');
      return;
    }

    // Set on shared prefs
    await _sharedPreferences.setString(
      '${loggedUser!.id}_appLanguage',
      language.name,
    );

    // Change on user object
    _loggedUser!.settings.appLanguage = language;
    notifyListeners();
  }

  /// Set new app theme
  Future<void> setAppTheme(AppTheme theme) async {
    if (_loggedUser == null) {
      log('No logged user to set theme');
      return;
    }

    // Set on shared prefs
    await _sharedPreferences.setString(
      '${loggedUser!.id}_appTheme',
      theme.name,
    );

    // Change on user object
    _loggedUser!.settings.appTheme = theme;
    notifyListeners();
  }

  /// Set new logged user
  Future<void> setLoggedUser(User user) async {
    // Set variable
    _loggedUser = user;

    // Change last login
    _lastLogin =
        _loggedUser!.isAdmin ? _loggedUser!.name! : _loggedUser!.store!.cnpj;
    await _sharedPreferences.setString(
      'lastLogin',
      _lastLogin!,
    );
    notifyListeners();
  }
}
