import '../database/partner_store_table.dart';

import 'autonomy_level.dart';
import 'sale.dart';
import 'vehicle.dart';

/// PartnerStore entity
class PartnerStore {
  /// Constructor
  PartnerStore({
    this.id,
    required this.cnpj,
    required this.name,
    required this.autonomyLevel,
  });

  /// ID for database identification
  int? id;

  /// CNPJ, 14 chars
  final String cnpj;

  /// Store name, 120 chars max
  final String name;

  /// Reference to [AutonomyLevel] table
  final AutonomyLevel autonomyLevel;

  /// List of all [Vehicle]s for this store
  final _vehicles = <Vehicle>[];

  /// Getter for vehicles
  List<Vehicle> get vehicles => _vehicles;

  /// Method to set vehicles
  set vehicles(List<Vehicle> items) {
    _vehicles
      ..clear()
      ..addAll(items);
  }

  /// List of all [Sale]s for this store
  final _sales = <Sale>[];

  /// Getter for sales
  List<Sale> get sales => _sales;

  /// Method to set sales
  set sales(List<Sale> items) {
    _sales
      ..clear()
      ..addAll(items);
  }

  /// Map representation of [PartnerStore]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[PartnerStoreTable.id] = id;
    map[PartnerStoreTable.cnpj] = cnpj;
    map[PartnerStoreTable.name] = name;
    map[PartnerStoreTable.autonomyLevelId] = autonomyLevel.id;

    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
