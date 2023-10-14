import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../entities/user.dart';
import '../utils/forms.dart';
import 'main_state.dart';

/// Provider for UserSettings page
class UserSettingsState with ChangeNotifier {
  /// Constructor
  UserSettingsState({required this.user, required this.mainState});

  /// Used to set app theme and language
  final MainState mainState;

  /// [User] object to get/set settings
  final User user;

  /// Get current app theme
  AppTheme get appTheme => user.settings.appTheme;

  /// Get current app language
  AppLanguage get appLanguage => user.settings.appLanguage;

  /// Method to change app theme
  Future<void> setAppTheme(AppTheme theme) async {
    // Update in main state provider
    await mainState.setAppTheme(theme);
  }

  /// Method to change app language
  Future<void> setAppLanguage(AppLanguage language) async {
    // Update in main state provider
    await mainState.setAppLanguage(language);
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
          // TODO: Dont use Provider.of()
          //  just get both onThemeChanged and onLanguageChanged on parameters
          mainState: Provider.of<MainState>(context, listen: false),
        );
      },
      child: Consumer<UserSettingsState>(
        builder: (_, state, __) {
          return Scaffold(
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
          );
        },
      ),
    );
  }
}
