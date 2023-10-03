import 'package:flutter/material.dart';

import 'utils/routes.dart';
import 'view/login.dart';

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
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/vehicle_register': vehicleRegisterRoute,
        '/vehicle_edit': vehicleEditRoute,
        '/sale_register': saleRegisterRoute,
        '/store_edit': storeEditRoute,
        '/home': homeRoute,
      },
    );
  }
}
