import '../database/user_table.dart';
import 'partner_store.dart';

/// User entity
class User {
  /// Constructor
  User({
    this.id,
    this.name,
    this.isAdmin = false,
    this.storeId,
    required this.password,
  });

  /// ID for database identification
  final int? id;

  /// Name for admin login
  final String? name;

  /// If this user is an admin, by default false
  final bool isAdmin;

  /// Reference for [PartnerStore] if not an admin
  final int? storeId;

  /// Encrypted password
  final String password;

  /// Map representation of [User] for database operations
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[UserTable.id] = id;
    map[UserTable.isAdmin] = isAdmin ? '1' : '0';
    map[UserTable.password] = password;
    map[UserTable.storeId] = storeId;
    map[UserTable.name] = name;

    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
