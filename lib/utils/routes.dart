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
      name: 'user_edit',
      path: '/user_edit',
      builder: userEditRoute,
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
          path: 'info/:id',
          redirect: (context, state) async {
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
          },
          builder: (context, state) {
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
          },
        ),
        GoRoute(
          path: 'register',
          redirect: (context, state) async {
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
          },
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            final partnerStore = args['partner_store'] as PartnerStore?;
            if (partnerStore == null) {
              throw 'Expected a not-null partner store, got: $partnerStore';
            }

            return VehicleRegisterForm(
              partnerStore: partnerStore,
              onRegister: args['on_register'],
            );
          },
        ),
        GoRoute(
          path: 'edit/:id',
          redirect: (context, state) async {
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
          },
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            final vehicle = args['vehicle'] as Vehicle?;
            if (vehicle == null) {
              throw 'Expected a not-null vehicle, got: $vehicle';
            }

            return VehicleEditForm(
              vehicle: vehicle,
              onEdit: args['on_edit'],
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/store',
      redirect: (context, state) {
        final fullPath = state.fullPath;

        // Route /vehicle is not supposed to be accessed
        if (fullPath == '/store') {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: 'info/:id',
          redirect: (context, state) async {
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
          },
          builder: (context, state) {
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
          },
        ),
        GoRoute(
          path: 'register',
          redirect: (context, state) async {
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
          },
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;

            return PartnerStoreRegisterForm(
              onRegister: args['on_register'],
            );
          },
        ),
        GoRoute(
          path: 'edit/:id',
          redirect: (context, state) async {
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
            return null;
          },
          builder: (context, state) {
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
          },
        ),
      ],
    ),
    GoRoute(
      path: '/sale',
      redirect: (context, state) {
        final fullPath = state.fullPath;

        // Route /sale is not supposed to be accessed
        if (fullPath == '/sale') {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: 'info/:id',
          redirect: (context, state) async {
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
          },
          builder: (context, state) {
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
          },
        ),
        GoRoute(
          path: 'register',
          redirect: (context, state) async {
            print('/sale/register redirect');
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
          },
          builder: (context, state) {
            print('/sale/register build');
            final args = state.extra as Map<String, dynamic>;
            final partnerStore = args['partner_store'] as PartnerStore?;
            if (partnerStore == null) {
              throw 'Expected a not-null partner store, got: $partnerStore';
            }

            return SaleRegisterForm(
              partnerStore: partnerStore,
              onRegister: args['on_register'],
            );
          },
        ),
      ],
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

  return PartnerStoreRegisterForm(onRegister: args['on_register']);
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

  return PartnerStoreEditPage(
    userId: user.id!,
    partnerStore: partnerStore,
    onEdit: args['on_edit'],
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

  return PartnerStoreInfoPage(partnerStore: partnerStore);
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

  return VehicleRegisterForm(
    partnerStore: partnerStore,
    onRegister: args['on_register'],
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

  return VehicleEditForm(
    vehicle: vehicle,
    onEdit: args['on_edit'],
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

  return VehicleInfoPage(vehicle: vehicle);
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

  return SaleRegisterForm(
    partnerStore: partnerStore,
    onRegister: args['on_register'],
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

  return SaleInfoPage(sale: args['sale']);
}

/// Function to handle /autonomy_level_register route
Widget autonomyLevelRegisterRoute(BuildContext context, GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;

  final localization = AppLocalizations.of(context)!;

  return Scaffold(
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
    appBar: AppBar(
      title: Text(localization.editAutonomyLevel),
    ),
    body: AutonomyLevelEditForm(
      autonomyLevel: autonomyLevel,
      onEdit: args['on_edit'],
    ),
  );
}
