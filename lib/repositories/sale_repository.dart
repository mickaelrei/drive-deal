import '../database/database.dart';
import '../database/sale_table.dart';

import '../entities/sale.dart';

/// Class for [Sale] table operations
class SaleRepository {
  /// Insert a [Sale] on the database [SaleTable] table
  Future<void> insert(Sale sale) async {
    final database = await getDatabase();
    final map = sale.toMap();

    await database.insert(SaleTable.tableName, map);
  }
}
