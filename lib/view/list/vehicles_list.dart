import 'package:flutter/material.dart';

import '../../entities/partner_store.dart';
import '../../entities/vehicle.dart';
import '../../repositories/vehicle_image_repository.dart';
import '../../usecases/vehicle_image_use_case.dart';

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

    return ListView.builder(
      itemCount: partnerStore.vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = partnerStore.vehicles[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: VehicleTile(vehicle: vehicle),
        );
      },
    );
  }
}

/// Widget for displaying a [Vehicle] in a [ListView]
class VehicleTile extends StatelessWidget {
  /// Constructor
  const VehicleTile({required this.vehicle, super.key});

  final VehicleImageRepository _vehicleImageRepository =
      const VehicleImageRepository();

  /// [Vehicle] object to show
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey,
      child: ListTile(
        title: Text(
          vehicle.model,
        ),
        subtitle: Text('${vehicle.brand}, ${vehicle.modelYear}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.cyan),
              onPressed: () {
                print('Edit');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                print('Remove');
              },
            )
          ],
        ),
        leading: vehicle.images.isNotEmpty
            ? FutureBuilder(
                future:
                    _vehicleImageRepository.loadImage(vehicle.images[0].name),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.data == null) {
                    return const NoVehicleTile();
                  }

                  return CircleAvatar(
                    backgroundImage: FileImage(
                      snapshot.data!,
                      // height: double.infinity,
                    ),
                  );
                },
              )
            : const NoVehicleTile(),
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
