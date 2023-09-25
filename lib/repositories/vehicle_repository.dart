import '../database/database.dart';
import '../database/vehicle_table.dart';

import '../entities/vehicle.dart';
import 'vehicle_image_repository.dart';

/// Class for [Vehicle] table operations
class VehicleRepository {
  /// Default constructor
  const VehicleRepository();

  final VehicleImageRepository _vehicleImageRepository =
      const VehicleImageRepository();

  /// Insert a [Vehicle] on the database [VehicleTable] table
  Future<int> insert(Vehicle vehicle) async {
    final database = await getDatabase();
    final map = vehicle.toMap();

    return await database.insert(VehicleTable.tableName, map);
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
      // Create vehicle object
      final vehicle = Vehicle(
        id: item[VehicleTable.id],
        storeId: item[VehicleTable.storeId],
        model: item[VehicleTable.model],
        brand: item[VehicleTable.brand],
        year: int.parse(item[VehicleTable.year]),
        modelYear: item[VehicleTable.modelYear],
        plate: item[VehicleTable.plate],
        fipePrice: item[VehicleTable.fipePrice],
        purchaseDate: DateTime.fromMillisecondsSinceEpoch(
          item[VehicleTable.purchaseDate],
        ),
      );

      // Get all images from this vehicle
      final images = await _vehicleImageRepository.select();
      images.removeWhere((image) => image.vehicleId != vehicle.id);
      vehicle.images = images;

      // Add to list
      list.add(vehicle);
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
