import '../entities/partner_store.dart';
import '../entities/sale.dart';

/// Class for [Sale] table representation
abstract class SaleTable {
  /// Used on table creation
  static const String createTable = '''
  CREATE TABLE $tableName(
    $id           INTEGER     PRIMARY KEY AUTOINCREMENT,
    $storeId      INTEGER     NOT NULL,
    $customerCpf  VARCHAR(11) NOT NULL,
    $customerName TEXT        NOT NULL,
    $saleDate     INTEGER     NOT NULL,
    $price        REAL        NOT NULL
  );
  ''';

  /// Table name in database
  static const String tableName = 'sale';

  /// ID for identification
  static const String id = 'id';

  /// For [PartnerStore] reference in database
  static const String storeId = 'store_id';

  /// CPF of customer, 11 chars
  static const String customerCpf = 'customer_cpf';

  /// Name of customer
  static const String customerName = 'customer_name';

  /// On what date the sale happened
  static const String saleDate = 'sale_date';

  /// Price of sale
  static const String price = 'price';
}
