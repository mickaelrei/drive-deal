import 'dart:async';

import 'package:flutter/material.dart';
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
import 'use_cases.dart';

/// Application main router, using package go_router
final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/login',
    ),
    GoRoute(
      path: '/login',
      builder: loginBuilder,
    ),
    GoRoute(
      path: '/home',
      builder: homeBuilder,
    ),
    GoRoute(
      path: '/user',
      redirect: baseRouteRedirect('/user'),
      routes: [
        GoRoute(
          path: 'edit/:id',
          redirect: userEditRedirect,
          builder: userEditBuilder,
        ),
      ],
    ),
    GoRoute(
      path: '/vehicle',
      redirect: baseRouteRedirect('/vehicle'),
      routes: [
        GoRoute(
          path: 'info/:id',
          redirect: vehicleInfoRedirect,
          builder: vehicleInfoBuilder,
        ),
        GoRoute(
          path: 'register',
          redirect: vehicleRegisterRedirect,
          builder: vehicleRegisterBuilder,
        ),
        GoRoute(
          path: 'edit/:id',
          redirect: vehicleEditRedirect,
          builder: vehicleEditBuilder,
        ),
      ],
    ),
    GoRoute(
      path: '/store',
      redirect: baseRouteRedirect('/store'),
      routes: [
        GoRoute(
          path: 'info/:id',
          redirect: storeInfoRedirect,
          builder: storeInfoBuilder,
        ),
        GoRoute(
          path: 'register',
          redirect: storeRegisterRedirect,
          builder: storeRegisterBuilder,
        ),
        GoRoute(
          path: 'edit/:id',
          redirect: storeEditRedirect,
          builder: storeEditBuilder,
        ),
      ],
    ),
    GoRoute(
      path: '/sale',
      redirect: baseRouteRedirect('/sale'),
      routes: [
        GoRoute(
          path: 'info/:id',
          redirect: saleInfoRedirect,
          builder: saleInfoBuilder,
        ),
        GoRoute(
          path: 'register',
          redirect: saleRegisterRedirect,
          builder: saleRegisterBuilder,
        ),
      ],
    ),
    GoRoute(
      path: '/autonomy_level',
      redirect: baseRouteRedirect('/autonomy_level'),
      routes: [
        GoRoute(
          path: 'register',
          redirect: autonomyLevelRegisterRedirect,
          builder: autonomyLevelRegisterBuilder,
        ),
        GoRoute(
          path: 'edit/:id',
          redirect: autonomyLevelEditRedirect,
          builder: autonomyLevelEditBuilder,
        ),
      ],
    ),
  ],
);

/// Function to handle /login route
Widget loginBuilder(BuildContext context, GoRouterState state) {
  return const LoginPage();
}

/// Function to handle /home route
Widget homeBuilder(BuildContext context, GoRouterState state) {
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

/// Function to handle redirections on /user/edit route
Future<String?> userEditRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // TODO: This would need some authentication (probably from login)
  //  as of right now, if you just pass another user's id, you have
  //  permission to edit it

  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Need args to get user id
    return '/';
  }
  var user = args['user'] as User?;

  // If user object was not passed, get it from path arg
  if (user == null) {
    final userId = state.pathParameters['id']!;
    final id = int.tryParse(userId);
    if (id == null) {
      throw 'Expected a not-null integer as '
          'user id, got: $id';
    }

    // Load user from db
    user = await userUseCase.selectById(id);
  }

  // Check for valid args
  if (user == null) {
    return '/';
  }

  // TODO: Check if logged user is the same as url user

  // If reached here, user has permission to edit
  return null;
}

/// Builder for /user_edit route
Widget userEditBuilder(BuildContext context, GoRouterState state) {
  // Get args
  final args = state.extra as Map<String, dynamic>;
  final user = args['user'] as User?;

  // Check for valid args
  if (user == null) {
    throw 'Expected a not-null user, got: $user';
  }

  return UserEditPage(
    user: user,
    onEdit: args['on_edit'],
  );
}

/// Function to handle redirections on /vehicle/info route
Future<String?> vehicleInfoRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Args is needed to get user id
    return '/';
  }
  var vehicle = args['vehicle'] as Vehicle?;
  final userId = args['user_id'] as int?;

  // If vehicle object was not passed, get it from path arg
  if (vehicle == null) {
    final vehicleId = state.pathParameters['id']!;
    final id = int.tryParse(vehicleId);
    if (id == null) {
      throw 'Expected a not-null integer as '
          'vehicle id, got: $vehicleId';
    }

    // Load vehicle from db if needed
    vehicle = await vehicleUseCase.selectById(id);
  }

  // Check for valid args
  // TODO: Don't just redirect to home page if vehicle was not
  //  found, VehicleInfoPage is supposed to show a message like
  //  "Vehicle not found"
  //  (also change this in partner and sale routes)
  if (vehicle == null || userId == null) {
    return '/';
  }

  // Check if any of the permission rules are met:
  // 1 - user is an admin
  // 2 - user is owner of store in which the vehicle is registered in

  // Get user
  final user = await userUseCase.selectById(userId);
  if (user == null) {
    // Invalid user
    return '/';
  }

  // Check if is admin
  if (user.isAdmin) {
    // Can proceed
    return null;
  }

  // Check if store id is the same
  if (user.store?.id == vehicle.storeId) {
    // Can proceed
    return null;
  }

  // If all fails, then user doesn't have permission
  return '/';
}

/// Builder for /vehicle/info route
Widget vehicleInfoBuilder(BuildContext context, GoRouterState state) {
  // Get path args
  final vehicleId = state.pathParameters['id']!;

  // Get args
  final args = state.extra as Map<String, dynamic>;
  final vehicle = args['vehicle'] as Vehicle?;
  final userId = args['user_id'] as int?;

  // Check for valid args
  if (userId == null) {
    throw 'Expected a valid not-null '
        'integer as user id, got: $userId';
  }

  // If a vehicle object was passed, use it on widget
  if (vehicle != null) {
    return VehicleInfoPage(vehicle: vehicle);
  }

  // Check if vehicle id is a valid number
  final id = int.tryParse(vehicleId);
  if (id == null) {
    throw 'Expected a valid integer as vehicle id, got: $vehicleId';
  }

  // If no vehicle object was passed, use path id
  return VehicleInfoPage(vehicleId: id);
}

/// Function to handle redirections on /vehicle/register route
Future<String?> vehicleRegisterRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Need args to get user id
    return '/';
  }
  final userId = args['user_id'] as int?;
  final partnerStore = args['partner_store'] as PartnerStore?;

  // Check for valid args
  if (userId == null || partnerStore == null) {
    return '/';
  }

  // A vehicle can be registered on a store only by
  // the owner of the store, so check if:
  // 1 - user exists and is owner of the store
  // 2 - user is not an admin

  // Get user
  final user = await userUseCase.selectById(userId);
  if (user == null) {
    // Invalid user
    return '/';
  }

  // Check if is admin
  if (user.isAdmin) {
    // Can't register
    return '/';
  }

  // Check store id
  if (user.store?.id != partnerStore.id) {
    // Different id, not the owner
    return '/';
  }

  // If reached here, user has permission to register
  return null;
}

/// Builder for /vehicle/register route
Widget vehicleRegisterBuilder(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;
  final partnerStore = args['partner_store'] as PartnerStore?;
  if (partnerStore == null) {
    throw 'Expected a not-null partner store, got: $partnerStore';
  }

  return VehicleRegisterForm(
    partnerStore: partnerStore,
    onRegister: args['on_register'],
  );
}

/// Function to handle redirections on /vehicle/edit route
Future<String?> vehicleEditRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Need args to get user id
    return '/';
  }
  var vehicle = args['vehicle'] as Vehicle?;
  final userId = args['user_id'] as int?;

  // If vehicle object was not passed, get it from path arg
  if (vehicle == null) {
    final vehicleId = state.pathParameters['id']!;
    final id = int.tryParse(vehicleId);
    if (id == null) {
      throw 'Expected a not-null integer as vehicle id, got: $id';
    }

    // Load vehicle from db
    vehicle = await vehicleUseCase.selectById(id);
  }

  // Check for valid args
  if (vehicle == null || userId == null) {
    return '/';
  }

  // A vehicle registered in a store can be edited only by
  // the owner of the store, so check if:
  // 1 - user exists and is owner of the store
  // 2 - user is not an admin

  // Get user
  final user = await userUseCase.selectById(userId);
  if (user == null) {
    // Invalid user
    return '/';
  }

  // Check if is admin
  if (user.isAdmin) {
    // Can't edit
    return '/';
  }

  // Check store id
  if (user.store?.id != vehicle.storeId) {
    // Different id, not the owner
    return '/';
  }

  // If reached here, user has permission to edit
  return null;
}

/// Builder for /vehicle/edit route
Widget vehicleEditBuilder(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;
  final vehicle = args['vehicle'] as Vehicle?;
  if (vehicle == null) {
    throw 'Expected a not-null vehicle, got: $vehicle';
  }

  return VehicleEditForm(
    vehicle: vehicle,
    onEdit: args['on_edit'],
  );
}

/// Function to handle redirections on /store/info route
Future<String?> storeInfoRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Args is needed to get user id
    return '/';
  }
  var store = args['partner_store'] as PartnerStore?;
  final userId = args['user_id'] as int?;

  // If partner store object was not passed, get it from path arg
  if (store == null) {
    final storeId = state.pathParameters['id']!;
    final id = int.tryParse(storeId);
    if (id == null) {
      throw 'Expected a not-null integer as '
          'partner store id, got: $id';
    }

    // Load partner store from db
    store = await partnerStoreUseCase.selectById(id);
  }

  // Check for valid args
  if (store == null || userId == null) {
    return '/';
  }

  // Check if any of the permission rules are met:
  // 1 - user is an admin
  // 2 - user is owner of the store

  // Get user
  final user = await userUseCase.selectById(userId);
  if (user == null) {
    // Invalid user
    return '/';
  }

  // Check if is admin
  if (user.isAdmin) {
    // Can proceed
    return null;
  }

  // Check if store id is the same
  if (user.store?.id == store.id) {
    // Can proceed
    return null;
  }

  // If all fails, then user doesn't have permission
  return '/';
}

/// Builder for /store/info route
Widget storeInfoBuilder(BuildContext context, GoRouterState state) {
  // Get path args
  final storeId = state.pathParameters['id']!;

  // Get args
  final args = state.extra as Map<String, dynamic>;
  final store = args['partner_store'] as PartnerStore?;
  final userId = args['user_id'] as int?;

  // Check for valid args
  if (userId == null) {
    throw 'Expected a valid not-null '
        'integer as user id, got: $userId';
  }

  // If a partner store object was passed, use it on widget
  if (store != null) {
    return PartnerStoreInfoPage(partnerStore: store);
  }

  // Check if partner store id is a valid number
  final id = int.tryParse(storeId);
  if (id == null) {
    throw 'Expected a valid integer as '
        'partner store id, got: $storeId';
  }

  // If no partner store object was passed, use path id
  return PartnerStoreInfoPage(partnerStoreId: id);
}

/// Function to handle redirections on /store/register route
Future<String?> storeRegisterRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Need args to get user id
    return '/';
  }
  final userId = args['user_id'] as int?;

  // Check for valid args
  if (userId == null) {
    return '/';
  }

  // Get user
  final user = await userUseCase.selectById(userId);
  if (user == null) {
    // Invalid user
    return '/';
  }

  // A partner store can only be registered by an admin
  if (!user.isAdmin) {
    return '/';
  }

  // If reached here, user has permission to register
  return null;
}

/// Builder for /store/register route
Widget storeRegisterBuilder(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  return PartnerStoreRegisterForm(
    onRegister: args['on_register'],
  );
}

/// Function to handle redirections on /store/edit route
Future<String?> storeEditRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Need args to get user id
    return '/';
  }
  var partnerStore = args['partner_store'] as PartnerStore?;
  final userId = args['user_id'] as int?;

  // If partner store object was not passed, get it from path arg
  if (partnerStore == null) {
    final partnerStoreId = state.pathParameters['id']!;
    final id = int.tryParse(partnerStoreId);
    if (id == null) {
      throw 'Expected a not-null integer as '
          'partner store id, got: $id';
    }

    // Load partner store from db
    partnerStore = await partnerStoreUseCase.selectById(id);
  }

  // Check for valid args
  if (partnerStore == null || userId == null) {
    return '/';
  }

  // A partner store can be edited only by
  // the owner of the store or by an admin, so check if any apply:
  // 1 - user exists and is owner of the store
  // 2 - user is an admin

  // Get user
  final user = await userUseCase.selectById(userId);
  if (user == null) {
    // Invalid user
    return '/';
  }

  // Check if is admin
  if (user.isAdmin) {
    // Can proceed
    return null;
  }

  // Check store id
  if (user.store?.id == partnerStore.id) {
    // Same id, the owner can proceed
    return null;
  }

  // If reached here, user doesn't have permission to edit
  return '/';
}

/// Builder for /store/edit route
Widget storeEditBuilder(BuildContext context, GoRouterState state) {
  // Get args
  final args = state.extra as Map<String, dynamic>;
  final partnerStore = args['partner_store'] as PartnerStore?;
  final userId = args['user_id'] as int?;

  // Check for valid args
  if (partnerStore == null) {
    throw 'Expected a not-null partnerStore, got: $partnerStore';
  }
  if (userId == null) {
    throw 'Expected a not-null integer'
        ' as user id, got: $userId';
  }

  return PartnerStoreEditPage(
    userId: userId,
    partnerStore: partnerStore,
    onEdit: args['on_edit'],
  );
}

/// Function to handle redirections on /sale/info route
Future<String?> saleInfoRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Args is needed to get user id
    return '/';
  }
  var sale = args['sale'] as Sale?;
  final userId = args['user_id'] as int?;

  // If sale object was not passed, get it from path arg
  if (sale == null) {
    final saleId = state.pathParameters['id']!;
    final id = int.tryParse(saleId);
    if (id == null) {
      throw 'Expected a not-null integer as '
          'sale id, got: $saleId';
    }

    // Load sale from db if needed
    sale = await saleUseCase.selectById(id);
  }

  // Check for valid args
  if (sale == null || userId == null) {
    return '/';
  }

  // Check if any of the permission rules are met:
  // 1 - user is an admin
  // 2 - user is owner of store in which the sale is registered in

  // Get user
  final user = await userUseCase.selectById(userId);
  if (user == null) {
    // Invalid user
    return '/';
  }

  // Check if is admin
  if (user.isAdmin) {
    // Can proceed
    return null;
  }

  // Check if store id is the same
  if (user.store?.id == sale.storeId) {
    // Can proceed
    return null;
  }

  // If all fails, then user doesn't have permission
  return '/';
}

/// Builder for /sale/info route
Widget saleInfoBuilder(BuildContext context, GoRouterState state) {
  // Get path args
  final saleId = state.pathParameters['id']!;

  // Get args
  final args = state.extra as Map<String, dynamic>;
  final sale = args['sale'] as Sale?;
  final userId = args['user_id'] as int?;

  // Check for valid args
  if (userId == null) {
    throw 'Expected a valid not-null '
        'integer as user id, got: $userId';
  }

  // If a sale object was passed, use it on widget
  if (sale != null) {
    return SaleInfoPage(sale: sale);
  }

  // Check if sale id is a valid number
  final id = int.tryParse(saleId);
  if (id == null) {
    throw 'Expected a valid integer as sale id, got: $saleId';
  }

  // If no sale object was passed, use path id
  return SaleInfoPage(saleId: id);
}

/// Function to handle redirections on /sale/register route
Future<String?> saleRegisterRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Need args to get user id
    return '/';
  }
  final userId = args['user_id'] as int?;
  final partnerStore = args['partner_store'] as PartnerStore?;

  // Check for valid args
  if (userId == null || partnerStore == null) {
    return '/';
  }

  // A sale can be registered on a store only by
  // the owner of the store, so check if:
  // 1 - user exists and is owner of the store
  // 2 - user is not an admin

  // Get user
  final user = await userUseCase.selectById(userId);
  if (user == null) {
    // Invalid user
    return '/';
  }

  // Check if is admin
  if (user.isAdmin) {
    // Can't register
    return '/';
  }

  // Check store id
  if (user.store?.id != partnerStore.id) {
    // Different id, not the owner
    return '/';
  }

  // If reached here, user has permission to register
  return null;
}

/// Builder for /sale/register route
Widget saleRegisterBuilder(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;
  final partnerStore = args['partner_store'] as PartnerStore?;
  if (partnerStore == null) {
    throw 'Expected a not-null partner store, got: $partnerStore';
  }

  return SaleRegisterForm(
    partnerStore: partnerStore,
    onRegister: args['on_register'],
  );
}

/// Function to handle redirections on /autonomy_level/register route
Future<String?> autonomyLevelRegisterRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Need args to get user id
    return '/';
  }
  final userId = args['user_id'] as int?;

  // Check for valid args
  if (userId == null) {
    return '/';
  }

  // A sale can only be registered by an admin

  // Get user
  final user = await userUseCase.selectById(userId);
  if (user == null) {
    // Invalid user
    return '/';
  }

  // Check if is admin
  if (!user.isAdmin) {
    // Can't register
    return '/';
  }

  // If reached here, user has permission to register
  return null;
}

/// Builder for /autonomy_level/register route
Widget autonomyLevelRegisterBuilder(
  BuildContext context,
  GoRouterState state,
) {
  final args = state.extra as Map<String, dynamic>;

  return AutonomyLevelRegisterForm(
    onRegister: args['on_register'],
  );
}

/// Function to handle redirections on /autonomy_level/edit route
Future<String?> autonomyLevelEditRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  // Get args
  final args = state.extra as Map<String, dynamic>?;
  if (args == null) {
    // Need args to get user id
    return '/';
  }
  var autonomyLevel = args['autonomy_level'] as AutonomyLevel?;
  final userId = args['user_id'] as int?;

  // If autonomy level object was not passed, get it from path arg
  if (autonomyLevel == null) {
    final autonomyLevelId = state.pathParameters['id']!;
    final id = int.tryParse(autonomyLevelId);
    if (id == null) {
      throw 'Expected a not-null integer as '
          'autonomy level id, got: $id';
    }

    // Load autonomy level from db
    autonomyLevel = await autonomyLevelUseCase.selectById(id);
  }

  // Check for valid args
  if (autonomyLevel == null || userId == null) {
    return '/';
  }

  // An autonomy level can only be edited by an admin

  // Get user
  final user = await userUseCase.selectById(userId);
  if (user == null) {
    // Invalid user
    return '/';
  }

  // Check if is admin
  if (!user.isAdmin) {
    // Can't edit
    return '/';
  }

  // If reached here, user has permission to edit
  return null;
}

/// Builder for /autonomy_level/edit route
Widget autonomyLevelEditBuilder(
  BuildContext context,
  GoRouterState state,
) {
  // Get args
  final args = state.extra as Map<String, dynamic>;
  final autonomyLevel = args['autonomy_level'] as AutonomyLevel?;
  final userId = args['user_id'] as int?;

  // Check for valid args
  if (autonomyLevel == null) {
    throw 'Expected a not-null autonomyLevel, got: $autonomyLevel';
  }
  if (userId == null) {
    throw 'Expected a not-null integer'
        ' as user id, got: $userId';
  }

  return AutonomyLevelEditForm(
    autonomyLevel: autonomyLevel,
    onEdit: args['on_edit'],
  );
}

/// Function that returns a redirect callback based on a route name
GoRouterRedirect baseRouteRedirect(String routeName) {
  return (context, state) {
    final fullPath = state.fullPath;

    // Given route is not supposed to be accessed
    if (fullPath == routeName) {
      return '/';
    }

    return null;
  };
}

/// Signature for redirect callback in go_router routes
typedef GoRouterRedirect = FutureOr<String?> Function(
  BuildContext context,
  GoRouterState state,
);
