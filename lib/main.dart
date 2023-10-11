import 'package:flutter/material.dart';

import 'utils/routes.dart';

void main() {
  runApp(const MyApp());
}

/// Main app
class MyApp extends StatelessWidget {
  /// Constructor
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
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
        '/autonomy_level_register': autonomyLevelRegisterRoute
      },
    );
  }
}
