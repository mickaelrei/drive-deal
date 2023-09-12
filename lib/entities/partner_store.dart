import '../database/partner_store_table.dart';
import 'autonomy_level.dart';

/// PartnerStore entity
class PartnerStore {
  /// Constructor
  PartnerStore({
    this.id,
    required this.cnpj,
    required this.name,
    required this.autonomyLevelId,
  });

  /// ID for database identification
  final int? id;

  /// CNPJ, 14 chars
  final String cnpj;

  /// Store name, 120 chars max
  final String name;

  /// Reference to [AutonomyLevel] table
  final int autonomyLevelId;

  /// Map representation of [PartnerStore]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[PartnerStoreTable.id] = id;
    map[PartnerStoreTable.cnpj] = cnpj;
    map[PartnerStoreTable.name] = name;
    map[PartnerStoreTable.autonomyLevelId] = autonomyLevelId;

    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
