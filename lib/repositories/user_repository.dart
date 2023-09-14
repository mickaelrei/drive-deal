import '../database/database.dart';
import '../database/user_table.dart';
import '../entities/user.dart';

/// Class for [User] table operations
class UserRepository {
  /// Insert a [User] on the database [UserTable] table
  Future<int> insert(User user) async {
    final database = await getDatabase();
    final map = user.toMap();

    return await database.insert(UserTable.tableName, map);
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
      list.add(User(
        id: item[UserTable.id],
        storeId: item[UserTable.storeId],
        isAdmin: item[UserTable.isAdmin] == 1,
        password: item[UserTable.password],
        name: item[UserTable.name],
      ));
    }

    return list;
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
