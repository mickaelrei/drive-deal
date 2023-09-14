import '../database/autonomy_level_table.dart';
import '../database/database.dart';

import '../entities/autonomy_level.dart';

/// Class for [AutonomyLevel] table operations
class AutonomyLevelRepository {
  /// Insert a [AutonomyLevel] on the database [AutonomyLevelTable] table
  Future<int> insert(AutonomyLevel autonomyLevel) async {
    final database = await getDatabase();
    final map = autonomyLevel.toMap();

    return await database.insert(AutonomyLevelTable.tableName, map);
  }

  /// Method to get all [AutonomyLevel] objects in [AutonomyLevelTable]
  Future<List<AutonomyLevel>> select() async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      AutonomyLevelTable.tableName,
    );

    // Convert query items to [AutonomyLevel] objects
    final list = <AutonomyLevel>[];
    for (final item in result) {
      list.add(AutonomyLevel(
        id: item[AutonomyLevelTable.id],
        label: item[AutonomyLevelTable.label],
        storePercent: item[AutonomyLevelTable.storePercent],
        networkPercent: item[AutonomyLevelTable.networkPercent],
      ));
    }

    return list;
  }

  /// Method to delete a specific [AutonomyLevel] from database
  Future<void> delete(AutonomyLevel autonomyLevel) async {
    final database = await getDatabase();

    await database.delete(
      AutonomyLevelTable.tableName,
      where: '${AutonomyLevelTable.id} = ?',
      whereArgs: [autonomyLevel.id],
    );
  }
}
