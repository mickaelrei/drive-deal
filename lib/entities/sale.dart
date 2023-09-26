import '../database/sale_table.dart';
import 'partner_store.dart';
import 'vehicle.dart';

/// Sale entity
class Sale {
  /// Constructor
  Sale({
    this.id,
    required this.storeId,
    required this.customerCpf,
    required this.customerName,
    required this.saleDate,
    required this.storeProfit,
    required this.networkProfit,
    required this.safetyProfit,
    required this.vehicle,
  });

  /// ID for database identification
  int? id;

  /// For [PartnerStore] reference in database
  final int storeId;

  /// CPF of customer, 11 chars
  final String customerCpf;

  /// Name of customer
  final String customerName;

  /// for [Vehicle] reference in database
  final Vehicle vehicle;

  /// On what date the sale happened
  final DateTime saleDate;

  /// How much of this sale went for the store
  final double storeProfit;

  /// How much of this sale went for the network
  final double networkProfit;

  /// How much of this sale went for network safety
  final double safetyProfit;

  /// Total price
  double get price => storeProfit + networkProfit + safetyProfit;

  /// Map representation of [Sale]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[SaleTable.id] = id;
    map[SaleTable.storeId] = storeId;
    map[SaleTable.customerCpf] = customerCpf;
    map[SaleTable.customerName] = customerName;
    map[SaleTable.vehicleId] = vehicle.id;
    map[SaleTable.saleDate] = saleDate.millisecondsSinceEpoch;
    map[SaleTable.storeProfit] = storeProfit;
    map[SaleTable.networkProfit] = networkProfit;
    map[SaleTable.safetyProfit] = safetyProfit;

    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
