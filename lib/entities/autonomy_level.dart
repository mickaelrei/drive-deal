import '../database/autonomy_level_table.dart';
import 'partner_store.dart';
import 'sale.dart';

/// Autonomy Level entity
class AutonomyLevel {
  /// Constructor
  AutonomyLevel({
    this.id,
    required this.label,
    required this.storePercent,
    required this.networkPercent,
  });

  /// ID for database identification
  int? id;

  /// Autonomy level label (beginner, intermediate, ...)
  final String label;

  /// [Sale]'s percent for [PartnerStore]
  final double storePercent;

  /// [Sale]'s percent for network
  final double networkPercent;

  /// Map representation of [AutonomyLevel]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[AutonomyLevelTable.id] = id;
    map[AutonomyLevelTable.label] = label;
    map[AutonomyLevelTable.storePercent] = storePercent;
    map[AutonomyLevelTable.networkPercent] = networkPercent;

    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
