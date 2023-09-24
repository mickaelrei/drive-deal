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
  Future<int> insert(VehicleImage vehicleImage) async {
    return await _vehicleImageRepository.insert(vehicleImage);
  }
}
