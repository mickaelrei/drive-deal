import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../entities/vehicle.dart';
import '../../repositories/vehicle_repository.dart';
import '../../usecases/vehicle_use_case.dart';
import '../../utils/dialogs.dart';

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
      // Get list of images for the vehicle
      final images = _vehicleUseCase.getImages(vehicle);

      // Add list to map
      _vehicleImages[vehicle] = images;
    }
  }

  /// Method to update list of cached images of the vehicles
  Future<void> updateImages() async {
    // Loop through every vehicle
    for (final vehicle in partnerStore.vehicles) {
      // Check if this vehicle doesn't have cached images
      if (_vehicleImages[vehicle] == null) {
        // Get list of images for the vehicle
        final images = _vehicleUseCase.getImages(vehicle);

        // Add list to map
        _vehicleImages[vehicle] = images;
      }
    }
  }

  /// Retrieve list of images with given vehicle
  Future<List<File>>? getImages(Vehicle vehicle) {
    return _vehicleImages[vehicle];
  }

  /// Method to delete a vehicle from the listing page
  void onDelete(Vehicle vehicle) async {
    // TODO: Instead of deleting, just mark as "sold" when a Sale
    //  gets registered on the vehicle
    log('Vehicle delete is disabled');

    // // Wait for database deletion
    // await _vehicleUseCase.delete(vehicle);

    // // Delete from list
    // partnerStore.vehicles.removeWhere((element) => element.id == vehicle.id);

    // // Delete from images map
    // _vehicleImages.removeWhere((key, value) => key.id == vehicle.id);

    // // Check for changes in vehicle list
    // await updateImages();
    // notifyListeners();
  }
}

/// Widget for listing [Vehicle]s
class VehicleListPage extends StatelessWidget {
  /// Constructor
  const VehicleListPage({required this.partnerStore, super.key});

  /// [Vehicle] objects will be listed from this [PartnerStore] object
  final PartnerStore partnerStore;

  @override
  Widget build(BuildContext context) {
    if (partnerStore.vehicles.isEmpty) {
      return const Center(
        child: Text(
          'No vehicles!',
          style: TextStyle(fontSize: 25),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) {
        return VehicleListState(partnerStore: partnerStore);
      },
      child: Consumer<VehicleListState>(
        builder: (_, state, __) {
          // TODO: Add a "sort-by" to sort by:
          //  - All
          //  - Sold
          //  - Not sold
          //  - Price
          //  - Purchase date
          //  -

          // TODO: Sort order:
          //  - Ascending
          //  - Descending
          return ListView.builder(
            itemCount: partnerStore.vehicles.length,
            itemBuilder: (context, index) {
              // Get vehicle object
              final vehicle = partnerStore.vehicles[index];

              // Get images for this vehicle
              final images = state.getImages(vehicle);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: VehicleTile(
                  vehicle: vehicle,
                  images: images,
                  onDelete: state.onDelete,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget for displaying a [Vehicle] in a [ListView]
class VehicleTile extends StatelessWidget {
  /// Constructor
  const VehicleTile(
      {required this.vehicle,
      required this.images,
      required this.onDelete,
      super.key});

  /// [Vehicle] object to show
  final Vehicle vehicle;

  /// List of images of the [Vehicle]
  final Future<List<File>>? images;

  /// Callback for deletion
  final void Function(Vehicle) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey,
      child: ListTile(
        title: Text(
          '${vehicle.sold ? '(SOLD) ' : ''}${vehicle.model}',
          // style: TextStyle(overflow: TextOverflow.ellipsis),
        ),
        subtitle: Text('${vehicle.brand}, ${vehicle.modelYear}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              splashRadius: 25,
              onPressed: () {
                log('Vehicle edit');
              },
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
              return const NoVehicleTile();
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
class NoVehicleTile extends StatelessWidget {
  /// Constructor
  const NoVehicleTile({super.key});

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
