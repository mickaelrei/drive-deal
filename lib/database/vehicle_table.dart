import '../entities/partner_store.dart';
import '../entities/vehicle.dart';

/// Class for [Vehicle] table representation
abstract class VehicleTable {
  /// Used on table creation
  static const String createTable = '''
  CREATE TABLE $tableName(
    $id            INTEGER    PRIMARY KEY AUTOINCREMENT,
    $storeId       INTEGER    NOT NULL,
    $model         TEXT       NOT NULL,
    $brand         TEXT       NOT NULL,
    $year          TEXT       NOT NULL,
    $modelYear     TEXT       NOT NULL,
    $plate         VARCHAR(7) NOT NULL,
    $fipePrice     REAL       NOT NULL,
    $purchaseDate  INTEGER    NOT NULL,
    $purchasePrice REAL       NOT NULL,
    $sold          INTEGER    NOT NULL
  );
  ''';

  /// Table name
  static const String tableName = 'vehicle';

  /// ID for database identification
  static const String id = 'id';

  /// Reference to [PartnerStore] in database
  static const String storeId = 'store_id';

  /// Used to get info on Fipe API
  static const String model = 'model';

  /// Used to get info on Fipe API
  static const String brand = 'brand';

  /// Model year, used on Fipe API
  static const String modelYear = 'model_year';

  /// Manufacture year
  static const String year = 'year';

  /// Plate, 7 chars in Brazilian format: AAA0A00
  static const String plate = 'plate';

  /// Vehicle price from Fipe API
  static const String fipePrice = 'fipe_price';

  /// Date on which this vehicle was purchased by the [PartnerStore]
  static const String purchaseDate = 'purchase_date';

  /// For how much the store purchased this vehicle
  static const String purchasePrice = 'purchase_price';

  /// Whether this vehicle is sold or not
  static const String sold = 'sold';
}
