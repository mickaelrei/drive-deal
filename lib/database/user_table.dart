import '../entities/partner_store.dart';
import '../entities/user.dart';

/// Class for [User] table representation
class UserTable {
  /// Used on table creation
  static const String createTable = '''
  CREATE TABLE $tableName(
    $id           INTEGER PRIMARY KEY AUTOINCREMENT,
    $isAdmin      INTEGER NOT NULL,
    $password     TEXT    NOT NULL,
    $name         TEXT,
    $storeId      INTEGER
  )
  ''';

  /// Table name
  static const String tableName = 'user';

  /// ID for database identification
  static const String id = 'id';

  /// Name for admin login
  static const String name = 'name';

  /// If this user is an admin
  static const String isAdmin = 'is_admin';

  /// Encrypted password
  static const String password = 'password';

  /// Reference for [PartnerStore] if not an admin
  static const String storeId = 'store_id';
}
