import '../database/database.dart';
import '../database/partner_store_table.dart';
import '../entities/partner_store.dart';

/// Class for [PartnerStore] table operations
class PartnerStoreRepository {
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
      list.add(PartnerStore(
        id: item[PartnerStoreTable.id],
        cnpj: item[PartnerStoreTable.cnpj],
        name: item[PartnerStoreTable.name],
        autonomyLevelId: item[PartnerStoreTable.autonomyLevelId],
      ));
    }

    return list;
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
