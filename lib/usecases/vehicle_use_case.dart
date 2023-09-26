import 'package:path/path.dart';

import '../entities/vehicle.dart';
import '../entities/vehicle_image.dart';
import '../repositories/vehicle_image_repository.dart';
import '../repositories/vehicle_repository.dart';
import 'vehicle_image_use_case.dart';

/// Class to be used for [Vehicle] operations
class VehicleUseCase {
  /// Constructor
  const VehicleUseCase(this._vehicleRepository);

  final VehicleRepository _vehicleRepository;

  /// To add images for a vehicle
  final VehicleImageUseCase _vehicleImageUseCase = const VehicleImageUseCase(
    VehicleImageRepository(),
  );

  /// Method to select from db
  Future<List<Vehicle>> select() async {
    return _vehicleRepository.select();
  }

  /// Method to insert a [Vehicle] in the database
  Future<void> insert(Vehicle vehicle, [List<String>? imagePaths]) async {
    // Insert vehicle
    final vehicleId = await _vehicleRepository.insert(vehicle);
    vehicle.id = vehicleId;

    if (imagePaths != null) {
      // Insert all images
      for (final path in imagePaths) {
        // Create object
        final vehicleImage = VehicleImage(
          name: basename(path),
          vehicleId: vehicleId,
        );
        vehicle.images.add(vehicleImage);

        // Insert on database
        await _vehicleImageUseCase.insert(vehicleImage, originalPath: path);
      }
    }
  }
}
