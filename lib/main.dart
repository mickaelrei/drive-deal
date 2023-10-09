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
        '/vehicle_register': vehicleRegisterRoute,
        '/vehicle_edit': vehicleEditRoute,
        '/sale_register': saleRegisterRoute,
        '/store_edit': storeEditRoute,
        '/home': homeRoute,
      },
    );
  }
}
