import '../database/database.dart';
import '../database/vehicle_image_table.dart';
import '../entities/vehicle_image.dart';

// TODO: Make [LocalImageRepository] built inside VehicleImageRepository
// TODO: On VehicleImage.delete(), delete all images from vehicle too

/// Class for [VehicleImage] table operations
class VehicleImageRepository {
  /// Default constructor
  const VehicleImageRepository();

  /// Insert a [VehicleImage] on the database [VehicleImageTable] table
  Future<int> insert(VehicleImage vehicleImage) async {
    final database = await getDatabase();
    final map = vehicleImage.toMap();

    return await database.insert(VehicleImageTable.tableName, map);
  }

  /// Method to get all [VehicleImage] objects in [VehicleImageTable]
  Future<List<VehicleImage>> select() async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      VehicleImageTable.tableName,
    );

    // Convert query items to [VehicleImage] objects
    final list = <VehicleImage>[];
    for (final item in result) {
      list.add(VehicleImage(
        id: item[VehicleImageTable.id],
        path: item[VehicleImageTable.path],
        vehicleId: item[VehicleImageTable.vehicleId],
      ));
    }

    return list;
  }

  /// Method to get a [VehicleImage] by given id
  Future<VehicleImage?> selectById(int id) async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      VehicleImageTable.tableName,
      where: '${VehicleImageTable.id} = ?',
      whereArgs: [id],
    );

    // Check if exists
    if (result.isNotEmpty) {
      final item = result.first;
      return VehicleImage(
        id: item[VehicleImageTable.id],
        path: item[VehicleImageTable.path],
        vehicleId: item[VehicleImageTable.vehicleId],
      );
    }

    // If no result, return null
    return null;
  }

  /// Method to delete a specific [VehicleImage] from database
  Future<void> delete(VehicleImage vehicleImage) async {
    final database = await getDatabase();

    await database.delete(
      VehicleImageTable.tableName,
      where: '${VehicleImageTable.id} = ?',
      whereArgs: [vehicleImage.id],
    );
  }
}
