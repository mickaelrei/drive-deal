import 'package:flutter/material.dart';

import 'entities/partner_store.dart';
import 'exceptions.dart';
import 'view/home/admin_home.dart';
import 'view/home/partner_home.dart';
import 'view/login.dart';
import 'view/register/sale_register.dart';
import 'view/register/vehicle_register.dart';

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
        '/sale_register': saleRegisterRoute,
        '/store_edit': storeEditRoute,
        '/home': homeRoute,
      },
    );
  }
}

/// Function to handle /home route
Widget homeRoute(BuildContext context) {
  // Get args to decide whether to open admin or partner home page
  final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  // Check if it's for admin
  if (args['is_admin']) {
    return const AdminHomePage();
  } else {
    // If no partnerStore, something went wrong
    final partnerStore = args['partner_store'];
    if (partnerStore == null || partnerStore.id == null) {
      throw InvalidPartnerStoreException(
        'Invalid PartnerStore: $partnerStore',
      );
    }

    return PartnerHomePage(
      partnerStore: partnerStore as PartnerStore,
    );
  }
}

/// Function to handle /store_edit route
Widget storeEditRoute(BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as PartnerStore;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Store edit'),
    ),
    body: Center(
      child: Text('Editing of store: ${args.name}'),
    ),
  );
}

/// Function to handle /vehicle_register route
Widget vehicleRegisterRoute(BuildContext context) {
  final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  // Check for valid args
  if (args['partner_store'] == null) {
    throw InvalidPartnerStoreException(
      'Invalid PartnerStore: ${args['partner_store']}',
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Vehicle register'),
    ),
    body: RegisterVehicleForm(
      partnerStore: args['partner_store'],
      onRegister: args['on_register'],
    ),
  );
}

/// Function to handle /sale_register route
Widget saleRegisterRoute(BuildContext context) {
  final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  // Check for valid args
  if (args['partner_store'] == null) {
    throw InvalidPartnerStoreException(
      'Invalid PartnerStore: ${args['partner_store']}',
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Sale register'),
    ),
    body: RegisterSaleForm(
      partnerStore: args['partner_store'],
      onRegister: args['on_register'],
    ),
  );
}
