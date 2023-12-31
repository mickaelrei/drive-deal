import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../entities/vehicle.dart';
import '../../repositories/vehicle_repository.dart';
import '../../usecases/vehicle_use_case.dart';

/// Provider for vehicle listing page
class VehicleListState with ChangeNotifier {
  /// Constructor
  VehicleListState({required this.partnerStore}) {
    init();
  }

  /// From which partner store are the vehicles from
  final PartnerStore partnerStore;

  /// For operations on [Vehicle] objects
  final VehicleUseCase _vehicleUseCase = const VehicleUseCase(
    VehicleRepository(),
  );

  /// List of images for each vehicle
  final _vehicleImages = <Vehicle, Future<List<File>>>{};

  /// Method to initialize images for each vehicle
  void init() async {
    for (final vehicle in partnerStore.vehicles) {
      await loadVehicleImages(vehicle);
    }
    notifyListeners();
  }

  /// Initialize [vehicle] images
  Future<void> loadVehicleImages(Vehicle vehicle) async {
    // Get list of images for the vehicle
    final images = _vehicleUseCase.getImages(vehicle);

    // Add list to map
    _vehicleImages[vehicle] = images;
  }

  /// Callback for vehicle edit
  Future<void> onEdit(Vehicle vehicle) async {
    // Load
    await loadVehicleImages(vehicle);

    // Update screen
    notifyListeners();
  }
}

/// Widget for listing [Vehicle]s
class VehicleListPage extends StatelessWidget {
  /// Constructor
  const VehicleListPage({
    required this.partnerStore,
    this.navBar,
    this.onVehicleRegister,
    super.key,
  });

  /// [Vehicle] objects will be listed from this [PartnerStore] object
  final PartnerStore partnerStore;

  /// Page navigation bar
  final Widget? navBar;

  /// Optional callback for when a vehicle gets registered
  final void Function(Vehicle)? onVehicleRegister;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    // Scaffold body
    late final Widget body;

    // Check if list of vehicles is empty
    if (partnerStore.vehicles.isEmpty) {
      body = Center(
        child: Text(
          localization.noVehicles,
          style: const TextStyle(fontSize: 25),
        ),
      );
    } else {
      body = ChangeNotifierProvider(
        create: (context) {
          return VehicleListState(partnerStore: partnerStore);
        },
        child: Consumer<VehicleListState>(
          builder: (_, state, __) {
            return ListView.builder(
              itemCount: partnerStore.vehicles.length,
              itemBuilder: (context, index) {
                // Get vehicle object
                final vehicle = partnerStore.vehicles[index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: VehicleTile(
                    vehicle: vehicle,
                    images: state._vehicleImages[vehicle],
                    onEdit: () async {
                      await Navigator.of(context).pushNamed(
                        '/vehicle_edit',
                        arguments: {
                          'vehicle': vehicle,
                          'on_edit': state.onEdit,
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(localization.vehicle(2)),
        actions: [
          IconButton(
            onPressed: () async {
              // Wait until finished registering vehicles
              await Navigator.of(context).pushNamed(
                '/vehicle_register',
                arguments: {
                  'partner_store': partnerStore,
                  'on_register': onVehicleRegister,
                },
              );
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      bottomNavigationBar: navBar,
      body: body,
    );
  }
}

/// Widget for displaying a [Vehicle] in a [ListView]
class VehicleTile extends StatelessWidget {
  /// Constructor
  const VehicleTile({
    required this.vehicle,
    required this.images,
    required this.onEdit,
    super.key,
  });

  /// [Vehicle] object to show
  final Vehicle vehicle;

  /// List of images of the [Vehicle]
  final Future<List<File>>? images;

  /// Callback for edit
  final void Function() onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey,
      child: ListTile(
        onTap: () async {
          await Navigator.of(context).pushNamed(
            '/vehicle_info',
            arguments: {
              'vehicle': vehicle,
            },
          );
        },
        title: Text(
          vehicle.model,
        ),
        subtitle: Text('${vehicle.brand}, ${vehicle.modelYear}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            vehicle.sold
                ? const IconButton(
                    icon: Icon(Icons.sell, color: Colors.red),
                    splashRadius: 1,
                    onPressed: null,
                  )
                : IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    splashRadius: 25,
                    onPressed: onEdit,
                  ),
          ],
        ),
        leading: FutureBuilder(
          future: images,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.data == null) {
              return const NoVehicleImage();
            }

            if (snapshot.data!.isEmpty) {
              return const NoVehicleImage();
            }

            return CircleAvatar(
              backgroundImage: Image.file(
                color: Colors.black,
                colorBlendMode: BlendMode.clear,
                snapshot.data!.first,
              ).image,
            );
          },
        ),
      ),
    );
  }
}

/// Widget for an image in a [VehicleTile] with no images
class NoVehicleImage extends StatelessWidget {
  /// Constructor
  const NoVehicleImage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundColor: Colors.transparent,
      child: Icon(
        Icons.directions_car_filled_rounded,
        color: Colors.grey,
      ),
    );
  }
}
