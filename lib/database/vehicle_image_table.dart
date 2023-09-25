import '../entities/vehicle.dart';
import '../entities/vehicle_image.dart';

/// Class for [VehicleImage] table representation
abstract class VehicleImageTable {
  /// Used on table creation
  static const String createTable = '''
  CREATE TABLE $tableName(
    $id             INTEGER PRIMARY KEY AUTOINCREMENT,
    $name           TEXT    NOT NULL,
    $vehicleId      INTEGER NOT NULL
  );
  ''';

  /// Table name in database
  static const String tableName = 'vehicle_image';

  /// ID for identification
  static const String id = 'id';

  /// Image name
  static const String name = 'name';

  /// Reference to [Vehicle] object
  static const String vehicleId = 'vehicle_id';
}
