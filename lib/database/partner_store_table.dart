import '../entities/partner_store.dart';

/// Class for [PartnerStore] table representation
abstract class PartnerStoreTable {
  /// Used on table creation
  static const String createTable = '''
  CREATE TABLE $tableName(
    $id              INTEGER      PRIMARY KEY AUTOINCREMENT,
    $autonomyLevelId INTEGER      NOT NULL,
    $cnpj            VARCHAR(14)  NOT NULL,
    $name            VARCHAR(120) NOT NULL
  );
  ''';

  /// Table name in database
  static const String tableName = 'partner_store';

  /// ID for identification
  static const String id = 'id';

  /// CNPJ, 14 chars
  static const String cnpj = 'cnpj';

  /// Store name, 120 chars max
  static const String name = 'name';

  /// Autonomy level
  static const String autonomyLevelId = 'autonomy_level_id';
}
