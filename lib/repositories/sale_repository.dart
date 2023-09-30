import 'dart:developer';

import '../database/database.dart';
import '../database/sale_table.dart';

import '../database/vehicle_table.dart';
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
    await database.update(
      VehicleTable.tableName,
      sale.vehicle.toMap(),
      where: '${VehicleTable.id} = ?',
      whereArgs: [sale.vehicle.id],
    );

    return saleId;
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
      final vehicle =
          await _vehicleRepository.selectById(item[SaleTable.vehicleId]);

      // Add object to list
      list.add(Sale(
        id: item[SaleTable.id],
        storeId: item[SaleTable.storeId],
        customerCpf: item[SaleTable.customerCpf],
        customerName: item[SaleTable.customerName],
        vehicle: vehicle!,
        saleDate: DateTime.fromMillisecondsSinceEpoch(item[SaleTable.saleDate]),
        storeProfit: item[SaleTable.storeProfit],
        networkProfit: item[SaleTable.networkProfit],
        safetyProfit: item[SaleTable.safetyProfit],
      ));
    }

    return list;
  }

  /// Method to delete a specific [Sale] from database
  Future<void> delete(Sale sale) async {
    log('Attempt to delete sale');
  }
}
