import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'entities/user.dart';
import 'utils/routes.dart';
import 'utils/use_cases.dart';
import 'view/main_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeUseCases();

  runApp(const MyApp());
}

/// Main app
class MyApp extends StatelessWidget {
  /// Constructor
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MainState>(
      create: (context) {
        return MainState();
      },
      child: Consumer<MainState>(
        builder: (_, state, __) {
          // Get current theme
          final themeData = state.appTheme == AppTheme.dark
              ? ThemeData.dark()
              : ThemeData.light();

          // Get current locale (language)
          final locale = state.appLanguage == AppLanguage.english
              ? const Locale('en')
              : const Locale('pt');

          log('Current language: ${state.appLanguage.name}');
          log('Current theme: ${state.appTheme.name}');

          return MaterialApp.router(
            routerConfig: router,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: themeData.copyWith(
              sliderTheme: const SliderThemeData(
                showValueIndicator: ShowValueIndicator.always,
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
