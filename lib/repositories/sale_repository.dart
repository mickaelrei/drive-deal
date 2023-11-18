import 'dart:developer';

import '../database/database.dart';
import '../database/sale_table.dart';
import '../entities/sale.dart';
import 'vehicle_repository.dart';

/// Class for [Sale] table operations
class SaleRepository {
  /// Default constructor
  const SaleRepository();

  final VehicleRepository _vehicleRepository = const VehicleRepository();

  /// Insert a [Sale] on the database [SaleTable] table
  Future<int> insert(Sale sale) async {
    final database = await getDatabase();
    final map = sale.toMap();

    // Insert sale
    final saleId = database.insert(SaleTable.tableName, map);

    // Set vehicle.sold to true
    sale.vehicle.sold = true;

    // Update in database
    await _vehicleRepository.update(sale.vehicle);

    return saleId;
  }

  /// Method to create a [Sale] object from a database query
  Future<Sale> fromQuery(Map<String, dynamic> query) async {
    // Get vehicle
    final vehicle =
        await _vehicleRepository.selectById(query[SaleTable.vehicleId]);

    // Create vehicle object
    final sale = Sale(
      id: query[SaleTable.id],
      storeId: query[SaleTable.storeId],
      customerCpf: query[SaleTable.customerCpf],
      customerName: query[SaleTable.customerName],
      saleDate: DateTime.fromMillisecondsSinceEpoch(query[SaleTable.saleDate]),
      storeProfit: query[SaleTable.storeProfit],
      networkProfit: query[SaleTable.networkProfit],
      safetyProfit: query[SaleTable.safetyProfit],
      vehicle: vehicle!,
    );

    return sale;
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
      list.add(await fromQuery(item));
    }

    return list;
  }

  /// Method to select a [Sale] with a given id
  Future<Sale?> selectById(int id) async {
    final database = await getDatabase();

    // Query
    final query = await database.query(
      SaleTable.tableName,
      where: '${SaleTable.id} = ?',
      whereArgs: [id],
    );

    // Check if exists
    if (query.isNotEmpty) {
      return fromQuery(query.first);
    }

    return null;
  }

  /// Method to delete a specific [Sale] from database
  Future<void> delete(Sale sale) async {
    log('Attempt to delete sale, ignoring');
  }
}
