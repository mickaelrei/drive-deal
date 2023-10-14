import 'dart:developer';

import 'package:flutter/material.dart';

import '../entities/user.dart';

/// Provider that holds information such as:
///
/// - App language
class MainState with ChangeNotifier {
  /// Constructor
  MainState();

  User? _loggedUser;

  /// Current logged user
  User? get loggedUser => _loggedUser;

  /// Current app language
  AppLanguage get appLanguage => loggedUser != null
      ? loggedUser!.settings.appLanguage
      : UserSettings.defaultAppLanguage;

  /// Current app theme
  AppTheme get appTheme => loggedUser != null
      ? loggedUser!.settings.appTheme
      : UserSettings.defaultAppTheme;

  /// Set new app language
  void setAppLanguage(AppLanguage language) {
    if (_loggedUser == null) {
      log('No logged user to set language');
      return;
    }

    // TODO: Set on shared prefs

    // Change on user object
    _loggedUser!.settings.appLanguage = language;
    notifyListeners();
  }

  /// Set new app theme
  void setAppTheme(AppTheme theme) {
    if (_loggedUser == null) {
      log('No logged user to set theme');
      return;
    }

    // TODO: Set on shared prefs

    // Change on user object
    _loggedUser!.settings.appTheme = theme;
    notifyListeners();
  }

  /// Set new logged user
  void setLoggedUser(User user) {
    _loggedUser = user;
    notifyListeners();
  }
}
