import 'dart:io';

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

  /// Method to select from db by given id
  Future<Vehicle?> selectById(int id) async {
    return _vehicleRepository.selectById(id);
  }

  /// Method to insert a [Vehicle] in the database
  Future<void> insert(Vehicle vehicle, [List<String>? imagePaths]) async {
    // Insert vehicle
    final vehicleId = await _vehicleRepository.insert(vehicle);
    vehicle.id = vehicleId;

    if (imagePaths == null) return;

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

  /// Method to update a [Vehicle] in the database
  Future<void> update(Vehicle vehicle, [List<String>? imagePaths]) async {
    await _vehicleRepository.update(vehicle);

    if (imagePaths == null) return;

    // Check for deleted images
    for (final originalImage in vehicle.images) {
      // Try to find a path with matching file name
      final result = imagePaths.where(
        (path) => basename(path) == originalImage.name,
      );

      // If didn't find, delete image
      if (result.isEmpty) {
        // Remove from list
        vehicle.images.removeWhere((image) => image == originalImage);

        // Delete from database
        await _vehicleImageUseCase.delete(originalImage);
      }
    }

    // Check for new images
    for (final path in imagePaths) {
      // Try to find an image with matching name
      final result = vehicle.images.where(
        (image) => image.name == basename(path),
      );

      // If didn't find, it's a new image
      if (result.isEmpty) {
        // Create object
        final vehicleImage = VehicleImage(
          name: basename(path),
          vehicleId: vehicle.id!,
        );

        // Add to vehicle list
        vehicle.images.add(vehicleImage);

        // Insert in database
        await _vehicleImageUseCase.insert(vehicleImage, originalPath: path);
      }
    }
  }

  /// Method to delete a [Vehicle] from the database
  Future<void> delete(Vehicle vehicle) async {
    await _vehicleRepository.delete(vehicle);
  }

  /// Method to get all images from a vehicle
  Future<List<File>> getImages(Vehicle vehicle) async {
    final images = <File>[];

    // Get all images
    for (final image in vehicle.images) {
      images.add(await _vehicleImageUseCase.loadImage(image.name));
    }

    return images;
  }
}
