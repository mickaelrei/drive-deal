import '../database/database.dart';
import '../database/sale_table.dart';

import '../entities/sale.dart';

/// Class for [Sale] table operations
class SaleRepository {
  /// Insert a [Sale] on the database [SaleTable] table
  Future<int> insert(Sale sale) async {
    final database = await getDatabase();
    final map = sale.toMap();

    return await database.insert(SaleTable.tableName, map);
  }

  /// Method to get all [Sale] objects in [SaleTable]
  Future<List<Sale>> select() async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      SaleTable.tableName,
    );

    // Convert query items to [Sale] objects
    final list = <Sale>[];
    for (final item in result) {
      list.add(Sale(
        id: item[SaleTable.id],
        storeId: item[SaleTable.storeId],
        customerCpf: item[SaleTable.customerCpf],
        customerName: item[SaleTable.customerName],
        saleDate: DateTime.fromMillisecondsSinceEpoch(item[SaleTable.saleDate]),
        price: item[SaleTable.price],
      ));
    }

    return list;
  }

  /// Method to delete a specific [Sale] from database
  Future<void> delete(Sale sale) async {
    final database = await getDatabase();

    await database.delete(
      SaleTable.tableName,
      where: '${SaleTable.id} = ?',
      whereArgs: [sale.id],
    );
  }
}
