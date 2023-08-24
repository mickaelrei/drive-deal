import '../entities/autonomy_level.dart';
import '../entities/partner_store.dart';
import '../entities/sale.dart';

/// Class for [AutonomyLevel] table representation
abstract class AutonomyLevelTable {
  /// Used on table creation
  static const String createTable = '''
  CREATE TABLE $tableName(
    $id             INTEGER PRIMARY KEY AUTOINCREMENT,
    $label          TEXT    NOT NULL,
    $storePercent   REAL    NOT NULL,
    $networkPercent REAL    NOT NULL
  );
  ''';

  /// Table name in database
  static const String tableName = 'autonomy_level';

  /// ID for identification
  static const String id = 'id';

  /// Autonomy level label (beginner, intermediate, ...)
  static const String label = 'label';

  /// [Sale]'s percent for [PartnerStore]
  static const String storePercent = 'store_percent';

  /// [Sale]'s percent for network
  static const String networkPercent = 'network_percent';
}
