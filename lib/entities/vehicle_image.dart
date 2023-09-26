import '../database/vehicle_image_table.dart';
import 'vehicle.dart';

/// Vehicle Image entity
class VehicleImage {
  /// Constructor
  VehicleImage({
    this.id,
    required this.name,
    required this.vehicleId,
  });

  /// ID for database identification
  int? id;

  /// Image name
  final String name;

  /// Reference to [Vehicle] in database
  int vehicleId;

  /// Map representation of [Vehicle]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[VehicleImageTable.id] = id;
    map[VehicleImageTable.name] = name;
    map[VehicleImageTable.vehicleId] = vehicleId;

    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
