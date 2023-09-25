import '../database/sale_table.dart';
import 'partner_store.dart';

/// Sale entity
class Sale {
  /// Constructor
  Sale({
    this.id,
    required this.store,
    required this.customerCpf,
    required this.customerName,
    required this.saleDate,
    required this.price,
  });

  /// ID for database identification
  final int? id;

  /// For [PartnerStore] reference in database
  final PartnerStore store;

  /// CPF of customer, 11 chars
  final String customerCpf;

  /// Name of customer
  final String customerName;

  /// On what date the sale happened
  final DateTime saleDate;

  /// Price of sale
  final double price;

  /// Map representation of [Sale]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[SaleTable.id] = id;
    map[SaleTable.storeId] = store.id;
    map[SaleTable.customerCpf] = customerCpf;
    map[SaleTable.customerName] = customerName;
    map[SaleTable.saleDate] = saleDate.millisecondsSinceEpoch;
    map[SaleTable.price] = price;

    return map;
  }
}
