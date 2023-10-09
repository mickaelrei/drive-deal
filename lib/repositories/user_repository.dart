import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import '../database/user_table.dart';
import '../entities/partner_store.dart';
import '../entities/user.dart';
import 'partner_store_repository.dart';

/// Class for [User] table operations
class UserRepository {
  /// Default constructor
  const UserRepository();

  /// To load [PartnerStore] object from partner user
  final PartnerStoreRepository _partnerStoreRepository =
      const PartnerStoreRepository();

  /// Insert a [User] on the database [UserTable] table
  Future<int> insert(User user) async {
    final database = await getDatabase();
    final map = user.toMap();

    return database.insert(UserTable.tableName, map);
  }

  /// Method to create a [User] from a db query
  Future<User> fromQuery(Map<String, dynamic> query) async {
    // Get partner store
    PartnerStore? partnerStore;
    if (query[UserTable.storeId] != null) {
      partnerStore = await _partnerStoreRepository.selectById(
        query[UserTable.storeId],
      );
    }

    // Create object
    final user = User(
      id: query[UserTable.id],
      store: partnerStore,
      isAdmin: query[UserTable.isAdmin] == 1,
      password: query[UserTable.password],
      name: query[UserTable.name],
    );

    // Load settings
    final sharedPreferences = await SharedPreferences.getInstance();

    // App theme
    final themeString = sharedPreferences.getString(
      '${user.id}_appTheme',
    );
    user.settings.appTheme = UserSettings.getAppTheme(themeString);

    // App language
    final languageString = sharedPreferences.getString(
      '${user.id}_appLanguage',
    );
    user.settings.appLanguage = UserSettings.getAppLanguage(languageString);

    // Return created user object
    return user;
  }

  /// Method to get all [User] objects in [UserTable]
  Future<List<User>> select() async {
    final database = await getDatabase();

    // Query all users
    final List<Map<String, dynamic>> result = await database.query(
      UserTable.tableName,
    );

    // Convert query items to [User] objects
    final list = <User>[];
    for (final item in result) {
      // Add to list
      list.add(await fromQuery(item));
    }

    return list;
  }

  /// Method to get a [User] by given id
  Future<User?> selectById(int id) async {
    final database = await getDatabase();

    // Query user
    final List<Map<String, dynamic>> result = await database.query(
      UserTable.tableName,
      where: '${UserTable.id} = ?',
      whereArgs: [id],
    );

    // Check if got result
    if (result.isNotEmpty) {
      return fromQuery(result.first);
    }

    return null;
  }

  /// Method to delete a specific [User] from database
  Future<void> delete(User user) async {
    final database = await getDatabase();

    await database.delete(
      UserTable.tableName,
      where: '${UserTable.id} = ?',
      whereArgs: [user.id],
    );
  }
}
