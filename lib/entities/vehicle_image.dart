import '../database/vehicle_image_table.dart';
import 'vehicle.dart';

/// Vehicle Image entity
class VehicleImage {
  /// Constructor
  VehicleImage({
    this.id,
    required this.path,
    required this.vehicleId,
  });

  /// ID for database identification
  final int? id;

  /// Image path
  final String path;

  /// Reference to [Vehicle] in database
  int vehicleId;

  /// Map representation of [Vehicle]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[VehicleImageTable.id] = id;
    map[VehicleImageTable.path] = path;
    map[VehicleImageTable.vehicleId] = vehicleId;

    return map;
  }
}
