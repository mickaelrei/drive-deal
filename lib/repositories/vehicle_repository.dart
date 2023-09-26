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

  /// Method to create a [Vehicle] object from a database query
  Future<Vehicle> fromQuery(Map<String, dynamic> query) async {
    // Create vehicle object
    final vehicle = Vehicle(
      id: query[VehicleTable.id],
      storeId: query[VehicleTable.storeId],
      model: query[VehicleTable.model],
      brand: query[VehicleTable.brand],
      year: int.parse(query[VehicleTable.year]),
      modelYear: query[VehicleTable.modelYear],
      plate: query[VehicleTable.plate],
      fipePrice: query[VehicleTable.fipePrice],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(
        query[VehicleTable.purchaseDate],
      ),
    );

    // Get all images from this vehicle
    final images = await _vehicleImageRepository.select();
    images.removeWhere((image) => image.vehicleId != vehicle.id);
    vehicle.images = images;

    return vehicle;
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
      // Add to list
      list.add(await fromQuery(item));
    }

    return list;
  }

  /// Method to get [Vehicle] by given id
  Future<Vehicle?> selectById(int id) async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      VehicleTable.tableName,
      where: '${VehicleTable.id} = ?',
      whereArgs: [id],
    );

    // Check if exists
    if (result.isNotEmpty) {
      return await fromQuery(result.first);
    }

    // If no result, return null
    return null;
  }

  /// Method to delete a specific [Vehicle] from database
  Future<void> delete(Vehicle vehicle) async {
    final database = await getDatabase();

    // TODO: Also delete all VehicleImages from this vehicle
    // TODO: Open a transaction for all operations
    await database.delete(
      VehicleTable.tableName,
      where: '${VehicleTable.id} = ?',
      whereArgs: [vehicle.id],
    );
  }
}
