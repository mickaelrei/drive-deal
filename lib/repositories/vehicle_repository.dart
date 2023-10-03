import '../database/database.dart';
import '../database/vehicle_image_table.dart';
import '../database/vehicle_table.dart';

import '../entities/vehicle.dart';
import '../usecases/vehicle_image_use_case.dart';
import 'vehicle_image_repository.dart';

/// Class for [Vehicle] table operations
class VehicleRepository {
  /// Default constructor
  const VehicleRepository();

  final VehicleImageUseCase _vehicleImageUseCase =
      const VehicleImageUseCase(VehicleImageRepository());

  /// Insert a [Vehicle] on the database [VehicleTable] table
  Future<int> insert(Vehicle vehicle) async {
    final database = await getDatabase();
    final map = vehicle.toMap();

    return database.insert(VehicleTable.tableName, map);
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
      sold: query[VehicleTable.sold] == 1,
    );

    // Get all images from this vehicle
    final images = await _vehicleImageUseCase.select();
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
      return fromQuery(result.first);
    }

    // If no result, return null
    return null;
  }

  /// Method to update a [Vehicle] in the database
  Future<void> update(Vehicle vehicle) async {
    final database = await getDatabase();

    await database.update(
      VehicleTable.tableName,
      vehicle.toMap(),
      where: '${VehicleTable.id} = ?',
      whereArgs: [vehicle.id],
    );
  }

  /// Method to delete a specific [Vehicle] from database
  Future<void> delete(Vehicle vehicle) async {
    final database = await getDatabase();

    // Open transaction for multiple operations
    await database.transaction((txn) async {
      final batch = txn.batch();

      // Delete vehicle
      batch.delete(
        VehicleTable.tableName,
        where: '${VehicleTable.id} = ?',
        whereArgs: [vehicle.id],
      );

      // Delete vehicle images
      batch.delete(
        VehicleImageTable.tableName,
        where: '${VehicleImageTable.vehicleId} = ?',
        whereArgs: [vehicle.id],
      );

      // Commit
      await batch.commit();
    });
  }
}
