import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'entities/user.dart';
import 'utils/routes.dart';
import 'view/main_state.dart';

void main() {
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

          return MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: themeData.copyWith(
              sliderTheme: const SliderThemeData(
                showValueIndicator: ShowValueIndicator.always,
              ),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: '/login',
            routes: const {
              '/login': loginRoute,
              '/home': homeRoute,
              '/user_edit': userEditRoute,
              '/store_register': storeRegisterRoute,
              '/store_edit': storeEditRoute,
              '/store_info': storeInfoRoute,
              '/vehicle_register': vehicleRegisterRoute,
              '/vehicle_edit': vehicleEditRoute,
              '/vehicle_info': vehicleInfoRoute,
              '/sale_register': saleRegisterRoute,
              '/sale_info': saleInfoRoute,
              '/autonomy_level_register': autonomyLevelRegisterRoute,
              '/autonomy_level_edit': autonomyLevelEditRoute,
            },
          );
        },
      ),
    );
  }
}
