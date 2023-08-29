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

  /// Method to get all [Vehicle] objects in [VehicleTable]
  Future<List<Vehicle>> select() async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      VehicleTable.tableName,
    );

    // Convert query items to [Vehicle] objects
    final list = <Vehicle>[];
    for (final item in result) {
      list.add(Vehicle(
        id: item[VehicleTable.id],
        storeId: item[VehicleTable.storeId],
        modelId: item[VehicleTable.modelId],
        brandId: item[VehicleTable.brandId],
        yearId: item[VehicleTable.yearId],
        modelYear: item[VehicleTable.modelYear],
        vehicleImage: item[VehicleTable.vehicleImage],
        plate: item[VehicleTable.plate],
        price: item[VehicleTable.price],
        purchaseDate: DateTime.fromMillisecondsSinceEpoch(
          item[VehicleTable.purchaseDate],
        ),
      ));
    }

    return list;
  }

  /// Method to delete a specific [Vehicle] from database
  Future<void> delete(Vehicle vehicle) async {
    final database = await getDatabase();

    await database.delete(
      VehicleTable.tableName,
      where: '${VehicleTable.id} = ?',
      whereArgs: [vehicle.id],
    );
  }
}
