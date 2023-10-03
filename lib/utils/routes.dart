import 'package:flutter/material.dart';

import '../entities/partner_store.dart';
import '../entities/vehicle.dart';
import '../view/edit/vehicle_edit.dart';
import '../view/home/admin_home.dart';
import '../view/home/partner_home.dart';
import '../view/register/sale_register.dart';
import '../view/register/vehicle_register.dart';

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
    final partnerStore = args['partner_store'] as PartnerStore?;
    if (partnerStore == null || partnerStore.id == null) {
      throw ArgumentError.value(
        partnerStore,
        'args[\'partner_store\']',
        'field \'partner_store\' in args should be not null with a non-null id',
      );
    }

    return PartnerHomePage(
      partnerStore: partnerStore,
    );
  }
}

/// Function to handle /store_edit route
Widget storeEditRoute(BuildContext context) {
  final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  // Check for valid args
  final partnerStore = args['partner_store'] as PartnerStore?;
  if (partnerStore == null || partnerStore.id == null) {
    throw ArgumentError.value(
      partnerStore,
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be not null with a non-null id',
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Store edit'),
    ),
    body: Center(
      child: Text('Editing of store: ${partnerStore.name}'),
    ),
  );
}

/// Function to handle /vehicle_register route
Widget vehicleRegisterRoute(BuildContext context) {
  final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  // Check for valid args
  final partnerStore = args['partner_store'] as PartnerStore?;
  if (partnerStore == null || partnerStore.id == null) {
    throw ArgumentError.value(
      partnerStore,
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be not null with a non-null id',
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Vehicle register'),
    ),
    body: RegisterVehicleForm(
      partnerStore: partnerStore,
      onRegister: args['on_register'],
    ),
  );
}

/// Function to handle /vehicle_edit route
Widget vehicleEditRoute(BuildContext context) {
  final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  // Check for valid args
  final vehicle = args['vehicle'] as Vehicle?;
  if (vehicle == null || vehicle.id == null) {
    throw ArgumentError.value(
      vehicle,
      'args[\'vehicle\']',
      'field \'vehicle\' in args should be not null with a non-null id',
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Vehicle edit'),
    ),
    body: EditVehicleForm(
      vehicle: args['vehicle'],
      onEdit: args['on_edit'],
    ),
  );
}

/// Function to handle /sale_register route
Widget saleRegisterRoute(BuildContext context) {
  final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  // Check for valid args
  final partnerStore = args['partner_store'] as PartnerStore?;
  if (partnerStore == null) {
    throw ArgumentError.value(
      partnerStore,
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be not null with a non-null id',
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Sale register'),
    ),
    body: RegisterSaleForm(
      partnerStore: partnerStore,
      onRegister: args['on_register'],
    ),
  );
}
