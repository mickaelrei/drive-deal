import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/user.dart';
import '../utils/forms.dart';

/// Provider for UserSettings page
class UserSettingsState with ChangeNotifier {
  /// Constructor
  UserSettingsState({required this.user}) {
    unawaited(init());
  }

  /// [User] object to get/set settings
  final User user;

  /// Get current app theme
  AppTheme get appTheme => user.settings.appTheme;

  /// Get current app language
  AppLanguage get appLanguage => user.settings.appLanguage;

  /// Shared prefs to get/set user settings
  late final SharedPreferences _sharedPreferences;

  /// Method to initialize user settings
  Future<void> init() async {
    // Get shared prefs instance
    _sharedPreferences = await SharedPreferences.getInstance();

    // Update screen
    notifyListeners();
  }

  /// Method to change app theme
  Future<void> setAppTheme(AppTheme theme) async {
    // Set in shared prefs
    await _sharedPreferences.setString(
      '${user.id}_appTheme',
      theme.name,
    );

    // Update in screen
    user.settings.appTheme = theme;
    notifyListeners();
  }

  /// Method to change app language
  Future<void> setAppLanguage(AppLanguage language) async {
    // Set in shared prefs
    await _sharedPreferences.setString(
      '${user.id}_appLanguage',
      language.name,
    );

    // Update in screen
    user.settings.appLanguage = language;
    notifyListeners();
  }
}

/// Widget for showing user settings
class UserSettingsPage extends StatelessWidget {
  /// Constructor
  const UserSettingsPage({
    required this.user,
    this.navBar,
    this.onThemeChanged,
    super.key,
  });

  /// From what user to get/set settings
  final User user;

  /// Page navigation bar
  final Widget? navBar;

  /// Callback for theme changing
  final void Function(AppTheme)? onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return UserSettingsState(user: user);
      },
      child: Consumer<UserSettingsState>(
        builder: (_, state, __) {
          return Theme(
            data: state.appTheme == AppTheme.dark
                ? ThemeData.dark()
                : ThemeData.light(),
            child: Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              bottomNavigationBar: navBar,
              body: Column(
                children: [
                  const FormTitle(title: 'Settings'),
                  Row(
                    children: [
                      const TextHeader(label: 'Dark mode'),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            value: state.appTheme == AppTheme.dark,
                            onChanged: (value) async {
                              // Get new theme
                              final newTheme =
                                  value ? AppTheme.dark : AppTheme.light;

                              // Set new theme
                              await state.setAppTheme(newTheme);

                              /// Call callback
                              if (onThemeChanged != null) {
                                onThemeChanged!(newTheme);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const TextHeader(label: 'App language'),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: DropdownMenu<AppLanguage>(
                              initialSelection: state.appLanguage,
                              onSelected: (language) async {
                                await state.setAppLanguage(language!);
                              },
                              dropdownMenuEntries: const [
                                DropdownMenuEntry<AppLanguage>(
                                  value: AppLanguage.english,
                                  label: 'English',
                                ),
                                DropdownMenuEntry<AppLanguage>(
                                  value: AppLanguage.portuguese,
                                  label: 'Portuguese',
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
