import 'package:flutter/material.dart';

import 'exceptions.dart';
import 'view/admin_home.dart';
import 'view/login.dart';
import 'view/partner_home.dart';

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
        '/home': (context) {
          // Get args to decide whether to open admin or partner home page
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;

          // Check if it's for admin
          if (args['isAdmin']) {
            return const AdminHomePage();
          } else {
            // If no partnerStore, something went wrong
            if (args['partnerStore'] == null) {
              throw InvalidPartnerStoreException(
                'field "partnerStore" '
                'not included in args',
              );
            }

            return PartnerHomePage(
              partnerStore: args['partnerStore']!,
            );
          }
        },
      },
    );
  }
}
