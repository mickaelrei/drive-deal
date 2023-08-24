import '../database/database.dart';
import '../database/partner_store_table.dart';

import '../entities/partner_store.dart';

/// Class for [PartnerStore] table operations
class PartnerStoreRepository {
  /// Insert a [PartnerStore] on the database [PartnerStoreTable] table
  Future<void> insert(PartnerStore partnerStore) async {
    final database = await getDatabase();
    final map = partnerStore.toMap();

    await database.insert(PartnerStoreTable.tableName, map);
  }
}
