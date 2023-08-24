import '../database/database.dart';
import '../database/vehicle_table.dart';

import '../entities/vehicle.dart';

/// Class for [Vehicle] table operations
class VehicleRepository {
  /// Insert a [Vehicle] on the database [VehicleTable] table
  Future<void> insert(Vehicle vehicle) async {
    final database = await getDatabase();
    final map = vehicle.toMap();

    await database.insert(VehicleTable.tableName, map);
  }
}
