import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/user.dart';
import '../utils/forms.dart';
import 'main_state.dart';

/// Provider for UserSettings page
class UserSettingsState with ChangeNotifier {
  /// Constructor
  UserSettingsState({required this.user, required this.mainState}) {
    unawaited(init());
  }

  ///
  final MainState mainState;

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
    // await _sharedPreferences.setString(
    //   '${user.id}_appTheme',
    //   theme.name,
    // );

    // Update in main state provider
    mainState.setAppTheme(theme);

    // Update in screen
    // user.settings.appTheme = theme;
    // notifyListeners();
  }

  /// Method to change app language
  Future<void> setAppLanguage(AppLanguage language) async {
    // Set in shared prefs
    // await _sharedPreferences.setString(
    //   '${user.id}_appLanguage',
    //   language.name,
    // );

    // Update in main state provider
    mainState.setAppLanguage(language);

    // Update in screen
    // user.settings.appLanguage = language;
  }
}

/// Widget for showing user settings
class UserSettingsPage extends StatelessWidget {
  /// Constructor
  const UserSettingsPage({
    required this.user,
    this.navBar,
    this.onThemeChanged,
    this.onLanguageChanged,
    super.key,
  });

  /// From what user to get/set settings
  final User user;

  /// Page navigation bar
  final Widget? navBar;

  /// Callback for theme changing
  final void Function(AppTheme)? onThemeChanged;

  /// Callback for language changing
  final void Function(AppLanguage)? onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (context) {
        return UserSettingsState(
          user: user,
          mainState: Provider.of<MainState>(context, listen: false),
        );
      },
      child: Consumer<UserSettingsState>(
        builder: (_, state, __) {
          return Theme(
            data: state.appTheme == AppTheme.dark
                ? ThemeData.dark()
                : ThemeData.light(),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(localization.settings),
              ),
              bottomNavigationBar: navBar,
              body: ListView(
                children: [
                  FormTitle(title: localization.settings),
                  Row(
                    children: [
                      TextHeader(label: localization.darkMode),
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
                      TextHeader(label: localization.appLanguage),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: DropdownMenu<AppLanguage>(
                              initialSelection: state.appLanguage,
                              onSelected: (language) async {
                                // Set new language
                                await state.setAppLanguage(language!);

                                // Call callback
                                if (onLanguageChanged != null) {
                                  onLanguageChanged!(language);
                                }
                              },
                              dropdownMenuEntries: [
                                DropdownMenuEntry<AppLanguage>(
                                  value: AppLanguage.english,
                                  label: localization.english,
                                ),
                                DropdownMenuEntry<AppLanguage>(
                                  value: AppLanguage.portuguese,
                                  label: localization.portuguese,
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
