import 'dart:io';

import '../entities/vehicle_image.dart';
import '../repositories/vehicle_image_repository.dart';

/// Class to be used for [VehicleImage] operations
class VehicleImageUseCase {
  /// Constructor
  const VehicleImageUseCase(this._vehicleImageRepository);

  final VehicleImageRepository _vehicleImageRepository;

  /// Method to select from db
  Future<List<VehicleImage>> select() async {
    return _vehicleImageRepository.select();
  }

  /// Method to insert a [VehicleImage] in the database
  Future<void> insert(
    VehicleImage vehicleImage, {
    required String originalPath,
  }) async {
    // Insert into database
    final id = await _vehicleImageRepository.insert(vehicleImage);
    vehicleImage.id = id;

    // Save image
    await _vehicleImageRepository.saveImage(File(originalPath));
  }

  /// Method to delete a [VehicleImage] from the database
  Future<void> delete(VehicleImage image) async {
    await _vehicleImageRepository.delete(image);
  }

  /// Method to load an image from a given name
  Future<File> loadImage(String imageName) async {
    return _vehicleImageRepository.loadImage(imageName);
  }
}
