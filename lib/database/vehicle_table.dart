import '../entities/partner_store.dart';
import '../entities/vehicle.dart';

/// Class for [Vehicle] table representation
abstract class VehicleTable {
  /// Used on table creation
  static const String createTable = '''
  CREATE TABLE $tableName(
    $id           INTEGER    PRIMARY KEY AUTOINCREMENT,
    $storeId      INTEGER    NOT NULL,
    $modelId      INTEGER    NOT NULL,
    $brandId      INTEGER    NOT NULL,
    $yearId       INTEGER    NOT NULL,
    $modelYear    TEXT       NOT NULL,
    $vehicleImage TEXT       NOT NULL,
    $plate        VARCHAR(7) NOT NULL,
    $price        REAL       NOT NULL,
    $purchaseDate INTEGER    NOT NULL
  );
  ''';

  /// Table name
  static const String tableName = 'vehicle';

  /// ID for database identification
  static const String id = 'id';

  /// Reference to [PartnerStore] in database
  static const String storeId = 'store_id';

  /// Used to get info on Fipe API
  static const String modelId = 'model_id';

  /// Used to get info on Fipe API
  static const String brandId = 'brand_id';

  /// Manufacture year, used on Fipe API
  static const String yearId = 'year_id';

  /// Model year
  static const String modelYear = 'model_year';

  /// Name of image file for this vehicle
  static const String vehicleImage = 'vehicle_image';

  /// Plate, 7 chars in Brazilian format: AAA0A00
  static const String plate = 'plate';

  /// Vehicle price
  static const String price = 'price';

  /// Date on which this vehicle was purchased by the [PartnerStore]
  static const String purchaseDate = 'purchase_date';
}
