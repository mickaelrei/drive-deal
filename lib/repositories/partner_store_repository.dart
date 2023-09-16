import '../database/database.dart';
import '../database/partner_store_table.dart';
import '../entities/partner_store.dart';
import 'autonomy_level_repository.dart';
import 'vehicle_repository.dart';

/// Class for [PartnerStore] table operations
class PartnerStoreRepository {
  /// Default constructor
  const PartnerStoreRepository();

  final AutonomyLevelRepository _autonomyLevelRepository =
      const AutonomyLevelRepository();

  final VehicleRepository _vehicleRepository = const VehicleRepository();

  /// Insert a [PartnerStore] on the database [PartnerStoreTable] table
  Future<int> insert(PartnerStore partnerStore) async {
    final database = await getDatabase();
    final map = partnerStore.toMap();

    return await database.insert(PartnerStoreTable.tableName, map);
  }

  /// Method to get all [PartnerStore] objects in [PartnerStoreTable]
  Future<List<PartnerStore>> select() async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      PartnerStoreTable.tableName,
    );

    // Convert query items to [PartnerStore] objects
    final list = <PartnerStore>[];
    for (final item in result) {
      // Get autonomy level
      final autonomyLevel = await _autonomyLevelRepository.selectById(
        item[PartnerStoreTable.autonomyLevelId],
      );

      // Create partner store object
      final store = PartnerStore(
        id: item[PartnerStoreTable.id],
        cnpj: item[PartnerStoreTable.cnpj],
        name: item[PartnerStoreTable.name],
        autonomyLevel: autonomyLevel!,
      );
      
      // Get all vehicles from this store
      final vehicles = await _vehicleRepository.select();
      vehicles.removeWhere((vehicle) => vehicle.storeId != store.id);

      // Add vehicles to list
      store.setVehicles(vehicles);

      // Add object to list
      list.add(store);
    }

    return list;
  }

  /// Method to get [PartnerStore] by given id
  Future<PartnerStore?> selectById(int id) async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      PartnerStoreTable.tableName,
      where: '${PartnerStoreTable.id} = ?',
      whereArgs: [id],
    );

    // Check if exists
    if (result.isNotEmpty) {
      final item = result.first;

      // Get autonomy level
      final autonomyLevel = await _autonomyLevelRepository.selectById(
        item[PartnerStoreTable.autonomyLevelId],
      );

      return PartnerStore(
        id: item[PartnerStoreTable.id],
        cnpj: item[PartnerStoreTable.cnpj],
        name: item[PartnerStoreTable.name],
        autonomyLevel: autonomyLevel!,
      );
    }

    // If no result, return null
    return null;
  }

  /// Method to get [PartnerStore] by given CNPJ
  Future<PartnerStore?> selectByCNPJ(String cnpj) async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      PartnerStoreTable.tableName,
      where: '${PartnerStoreTable.cnpj} = ?',
      whereArgs: [cnpj],
    );

    // Check if exists
    if (result.isNotEmpty) {
      final item = result.first;

      // Get autonomy level
      final autonomyLevel = await _autonomyLevelRepository.selectById(
        item[PartnerStoreTable.autonomyLevelId],
      );

      return PartnerStore(
        id: item[PartnerStoreTable.id],
        cnpj: item[PartnerStoreTable.cnpj],
        name: item[PartnerStoreTable.name],
        autonomyLevel: autonomyLevel!,
      );
    }

    // If no result, return null
    return null;
  }

  /// Method to delete a specific [PartnerStore] from database
  Future<void> delete(PartnerStore partnerStore) async {
    final database = await getDatabase();

    await database.delete(
      PartnerStoreTable.tableName,
      where: '${PartnerStoreTable.id} = ?',
      whereArgs: [partnerStore.id],
    );
  }
}
