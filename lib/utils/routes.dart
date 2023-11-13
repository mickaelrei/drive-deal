import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../entities/autonomy_level.dart';
import '../entities/partner_store.dart';
import '../entities/sale.dart';
import '../entities/user.dart';
import '../entities/vehicle.dart';
import '../view/edit/autonomy_level_edit.dart';
import '../view/edit/partner_store_edit.dart';
import '../view/edit/user_edit.dart';
import '../view/edit/vehicle_edit.dart';
import '../view/home/admin_home.dart';
import '../view/home/partner_home.dart';
import '../view/info/partner_store_info.dart';
import '../view/info/sale_info.dart';
import '../view/info/vehicle_info.dart';
import '../view/login.dart';
import '../view/register/autonomy_level_register.dart';
import '../view/register/partner_store_register.dart';
import '../view/register/sale_register.dart';
import '../view/register/vehicle_register.dart';

/// Application main router, using package go_router
final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/login',
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: loginRoute,
    ),
    GoRoute(
      name: 'home',
      path: '/home',
      builder: homeRoute,
    ),
    GoRoute(
      path: '/vehicle',
      redirect: (context, state) {
        final fullPath = state.fullPath;

        // Route /vehicle is not supposed to be accessed
        if (fullPath == '/vehicle') {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final vehicle = state.extra as Vehicle?;
            final vehicleId = state.pathParameters['id']!;

            final localization = AppLocalizations.of(context)!;

            // If a vehicle object was passed, use it on widget
            if (vehicle != null) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  title: Text(localization.vehicleInfo),
                ),
                body: VehicleInfoPage(
                  vehicle: vehicle,
                ),
              );
            }

            // Check if id is a valid number
            final id = int.tryParse(vehicleId);
            if (id == null) {
              throw 'Expected a valid integer as vehicle id, got: $vehicleId';
            }

            // If no vehicle object was passed, use path id
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(localization.vehicleInfo),
              ),
              body: VehicleInfoPage(
                vehicleId: id,
              ),
            );
          },
        ),
      ],
    ),

    // GoRoute(
    //   name: 'vehicle_register',
    //   path: '/vehicle_register',
    //   builder: vehicleRegisterRoute,
    // ),
    // GoRoute(
    //   name: 'vehicle_edit',
    //   path: '/vehicle_edit',
    //   builder: vehicleEditRoute,
    // ),
    // GoRoute(
    //   name: 'vehicle_info',
    //   path: '/vehicle_info',
    //   builder: vehicleInfoRoute,
    // ),
    GoRoute(
      name: 'user_edit',
      path: '/user_edit',
      builder: userEditRoute,
    ),
    GoRoute(
      name: 'store_register',
      path: '/store_register',
      builder: storeRegisterRoute,
    ),
    GoRoute(
      name: 'store_edit',
      path: '/store_edit',
      builder: storeEditRoute,
    ),
    GoRoute(
      name: 'store_info',
      path: '/store_info',
      builder: storeInfoRoute,
    ),
    GoRoute(
      name: 'sale_register',
      path: '/sale_register',
      builder: saleRegisterRoute,
    ),
    GoRoute(
      name: 'sale_info',
      path: '/sale_info',
      builder: saleInfoRoute,
    ),
    GoRoute(
      name: 'autonomy_level_register',
      path: '/autonomy_level_register',
      builder: autonomyLevelRegisterRoute,
    ),
    GoRoute(
      name: 'autonomy_level_edit',
      path: '/autonomy_level_edit',
      builder: autonomyLevelEditRoute,
    ),
  ],
);

/// Function to handle /login route
Widget loginRoute(BuildContext context, GoRouterState state) {
  return const LoginPage();
}

/// Function to handle /home route
Widget homeRoute(BuildContext context, GoRouterState state) {
  // Get args to decide whether to open admin or partner home page
  final args = state.extra as Map<String, dynamic>;

  if (args['user'] is! User) {
    throw ArgumentError.value(
      args['user'],
      'args[\'user\']',
      'field \'user\' in args should be of type \'User\'',
    );
  }

  // Get user
  final user = args['user'] as User?;
  if (user == null || user.id == null) {
    throw ArgumentError.value(
      user,
      'args[\'user\']',
      'field \'user\' in args should be not null with a non-null id',
    );
  }

  // Check if it's for admin
  if (user.isAdmin) {
    return AdminHomePage(user: user);
  } else {
    return PartnerHomePage(user: user);
  }
}

/// Function to handle /user_edit route
Widget userEditRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  if (args['user'] is! User) {
    throw ArgumentError.value(
      args['user'],
      'args[\'user\']',
      'field \'user\' in args should be of type \'User\'',
    );
  }

  // Check for valid args
  final user = args['user'] as User?;
  if (user == null || user.id == null) {
    throw ArgumentError.value(
      user,
      'args[\'user\']',
      'field \'user\' in args should be not null with a non-null id',
    );
  }

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(localization.editUser),
    ),
    body: Center(
      child: UserEditPage(
        user: user,
        onEdit: args['on_edit'],
      ),
    ),
  );
}

/// Function to handle /store_register route
Widget storeRegisterRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    appBar: AppBar(
      title: Text(localization.registerPartnerStore),
    ),
    body: PartnerStoreRegisterForm(
      onRegister: args['on_register'],
    ),
  );
}

/// Function to handle /store_edit route
Widget storeEditRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  if (args['user'] is! User) {
    throw ArgumentError.value(
      args['user'],
      'args[\'user\']',
      'field \'user\' in args should be of type \'User\'',
    );
  }

  if (args['partner_store'] is! PartnerStore) {
    throw ArgumentError.value(
      args['partner_store'],
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be of type \'PartnerStore\'',
    );
  }

  // Check for valid args
  final user = args['user'] as User?;
  if (user == null || user.id == null) {
    throw ArgumentError.value(
      user,
      'args[\'user\']',
      'field \'user\' in args should be not null with a non-null id',
    );
  }

  final partnerStore = args['partner_store'] as PartnerStore?;
  if (partnerStore == null || partnerStore.id == null) {
    throw ArgumentError.value(
      partnerStore,
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be not null with a non-null id',
    );
  }

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(localization.editPartnerStore),
    ),
    body: Center(
      child: PartnerStoreEditPage(
        user: user,
        partnerStore: partnerStore,
        onEdit: args['on_edit'],
      ),
    ),
  );
}

/// Function to handle /store_info route
Widget storeInfoRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  if (args['partner_store'] is! PartnerStore) {
    throw ArgumentError.value(
      args['partner_store'],
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be of type \'PartnerStore\'',
    );
  }

  // Check for valid args
  final partnerStore = args['partner_store'] as PartnerStore?;
  if (partnerStore == null || partnerStore.id == null) {
    throw ArgumentError.value(
      partnerStore,
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be not null with a non-null id',
    );
  }

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(localization.partnerStoreInfo),
    ),
    body: PartnerStoreInfoPage(
      partnerStore: partnerStore,
    ),
  );
}

/// Function to handle /vehicle_register route
Widget vehicleRegisterRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  if (args['partner_store'] is! PartnerStore) {
    throw ArgumentError.value(
      args['partner_store'],
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be of type \'PartnerStore\'',
    );
  }

  // Check for valid args
  final partnerStore = args['partner_store'] as PartnerStore?;
  if (partnerStore == null || partnerStore.id == null) {
    throw ArgumentError.value(
      partnerStore,
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be not null with a non-null id',
    );
  }

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(localization.registerVehicle),
    ),
    body: VehicleRegisterForm(
      partnerStore: partnerStore,
      onRegister: args['on_register'],
    ),
  );
}

/// Function to handle /vehicle_edit route
Widget vehicleEditRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  if (args['vehicle'] is! Vehicle) {
    throw ArgumentError.value(
      args['vehicle'],
      'args[\'vehicle\']',
      'field \'vehicle\' in args should be of type \'Sale\'',
    );
  }

  // Check for valid args
  final vehicle = args['vehicle'] as Vehicle?;
  if (vehicle == null || vehicle.id == null) {
    throw ArgumentError.value(
      vehicle,
      'args[\'vehicle\']',
      'field \'vehicle\' in args should be not null with a non-null id',
    );
  }

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(localization.editVehicle),
    ),
    body: VehicleEditForm(
      vehicle: vehicle,
      onEdit: args['on_edit'],
    ),
  );
}

/// Function to handle /vehicle_info route
Widget vehicleInfoRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  if (args['vehicle'] is! Vehicle) {
    throw ArgumentError.value(
      args['vehicle'],
      'args[\'vehicle\']',
      'field \'vehicle\' in args should be of type \'Sale\'',
    );
  }

  // Check for valid args
  final vehicle = args['vehicle'] as Vehicle?;
  if (vehicle == null || vehicle.id == null) {
    throw ArgumentError.value(
      vehicle,
      'args[\'vehicle\']',
      'field \'vehicle\' in args should be not null with a non-null id',
    );
  }

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(localization.vehicleInfo),
    ),
    body: VehicleInfoPage(
      vehicle: vehicle,
    ),
  );
}

/// Function to handle /sale_register route
Widget saleRegisterRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  if (args['partner_store'] is! PartnerStore) {
    throw ArgumentError.value(
      args['partner_store'],
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be of type \'PartnerStore\'',
    );
  }

  // Check for valid args
  final partnerStore = args['partner_store'] as PartnerStore?;
  if (partnerStore == null) {
    throw ArgumentError.value(
      partnerStore,
      'args[\'partner_store\']',
      'field \'partner_store\' in args should be not null with a non-null id',
    );
  }

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(localization.registerSale),
    ),
    body: SaleRegisterForm(
      partnerStore: partnerStore,
      onRegister: args['on_register'],
    ),
  );
}

/// Function to handle /sale_info route
Widget saleInfoRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  if (args['sale'] is! Sale) {
    throw ArgumentError.value(
      args['sale'],
      'args[\'sale\']',
      'field \'sale\' in args should be of type \'Sale\'',
    );
  }

  // Check for valid args
  final sale = args['sale'] as Sale?;
  if (sale == null || sale.id == null) {
    throw ArgumentError.value(
      sale,
      'args[\'sale\']',
      'field \'sale\' in args should be not null with a non-null id',
    );
  }

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(localization.saleInfo),
    ),
    body: SaleInfoPage(
      sale: args['sale'],
    ),
  );
}

/// Function to handle /autonomy_level_register route
Widget autonomyLevelRegisterRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(localization.registerAutonomyLevel),
    ),
    body: AutonomyLevelRegisterForm(
      onRegister: args['on_register'],
    ),
  );
}

/// Function to handle /autonomy_level_edit route
Widget autonomyLevelEditRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  if (args['autonomy_level'] is! AutonomyLevel) {
    throw ArgumentError.value(
      args['autonomy_level'],
      'args[\'autonomy_level\']',
      'field \'autonomy_level\' in args should be of type \'AutonomyLevel\'',
    );
  }

  // Check for valid args
  final autonomyLevel = args['autonomy_level'] as AutonomyLevel?;
  if (autonomyLevel == null || autonomyLevel.id == null) {
    throw ArgumentError.value(
      autonomyLevel,
      'args[\'autonomy_level\']',
      'field \'autonomy_level\' in args should be not null with a non-null id',
    );
  }

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(localization.editAutonomyLevel),
    ),
    body: AutonomyLevelEditForm(
      autonomyLevel: autonomyLevel,
      onEdit: args['on_edit'],
    ),
  );
}
