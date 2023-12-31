import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'autonomy_level_table.dart';
import 'partner_store_table.dart';
import 'sale_table.dart';
import 'user_table.dart';
import 'vehicle_image_table.dart';
import 'vehicle_table.dart';

/// Get [Database] reference for operations
Future<Database> getDatabase() async {
  final path = join(
    await getDatabasesPath(),
    'drive_deal.db',
  );

  return openDatabase(
    path,
    onCreate: (db, version) async {
      // Create tables
      await db.execute(AutonomyLevelTable.createTable);
      await db.execute(PartnerStoreTable.createTable);
      await db.execute(SaleTable.createTable);
      await db.execute(UserTable.createTable);
      await db.execute(VehicleTable.createTable);
      await db.execute(VehicleImageTable.createTable);

      // Create admin user
      await db.rawInsert(
        'INSERT INTO ${UserTable.tableName}'
        '(${UserTable.isAdmin},'
        ' ${UserTable.storeId},'
        ' ${UserTable.name},'
        ' ${UserTable.password}) '
        'VALUES(1, NULL, \'anderson\', \'admin123\')',
      );

      // Create autonomy levels
      // Beginner
      await db.rawInsert(
        'INSERT INTO ${AutonomyLevelTable.tableName}'
        '(${AutonomyLevelTable.label},'
        ' ${AutonomyLevelTable.networkPercent},'
        ' ${AutonomyLevelTable.storePercent}) '
        'VALUES(\'Beginner\', 25, 74)',
      );

      // Intermediate
      await db.rawInsert(
        'INSERT INTO ${AutonomyLevelTable.tableName}'
        '(${AutonomyLevelTable.label},'
        ' ${AutonomyLevelTable.networkPercent},'
        ' ${AutonomyLevelTable.storePercent}) '
        'VALUES(\'Intermediate\', 20, 79)',
      );

      // Advanced
      await db.rawInsert(
        'INSERT INTO ${AutonomyLevelTable.tableName}'
        '(${AutonomyLevelTable.label},'
        ' ${AutonomyLevelTable.networkPercent},'
        ' ${AutonomyLevelTable.storePercent}) '
        'VALUES(\'Advanced\', 15, 84)',
      );

      // Special
      await db.rawInsert(
        'INSERT INTO ${AutonomyLevelTable.tableName}'
        '(${AutonomyLevelTable.label},'
        ' ${AutonomyLevelTable.networkPercent},'
        ' ${AutonomyLevelTable.storePercent}) '
        'VALUES(\'Special\', 5, 94)',
      );

      // Create testing partner store
      final storeId = await db.rawInsert(
        'INSERT INTO ${PartnerStoreTable.tableName}'
        '(${PartnerStoreTable.cnpj},'
        ' ${PartnerStoreTable.name},'
        ' ${PartnerStoreTable.autonomyLevelId}) '
        'VALUES(\'12345678901234\', \'Daniel Automóveis\', 1)',
      );

      // Create user for partner store
      await db.rawInsert(
        'INSERT INTO ${UserTable.tableName}'
        '(${UserTable.isAdmin},'
        ' ${UserTable.storeId},'
        ' ${UserTable.name},'
        ' ${UserTable.password}) '
        'VALUES(0, $storeId, NULL, \'user123\')',
      );
    },
    version: 1,
  );
}
