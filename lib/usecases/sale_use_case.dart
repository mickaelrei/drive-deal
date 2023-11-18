import '../entities/autonomy_level.dart';
import '../entities/sale.dart';
import '../repositories/sale_repository.dart';
import '../utils/safety_percent.dart';

/// Class to be used for [Sale] operations
class SaleUseCase {
  /// Constructor
  const SaleUseCase(this._saleRepository);

  final SaleRepository _saleRepository;

  /// Method to select from db
  Future<List<Sale>> select() async {
    return _saleRepository.select();
  }

  /// Method to select a sale by given id
  Future<Sale?> selectById(int id) async {
    return _saleRepository.selectById(id);
  }

  /// Method to insert a [Sale] in the database
  Future<void> insert(Sale sale) async {
    // Insert sale
    final id = await _saleRepository.insert(sale);
    sale.id = id;
  }

  /// Method to calculate the store's profit on a sale,
  /// given sale's total price and store's autonomy level
  double calculateStoreProfit({
    required double totalPrice,
    required AutonomyLevel autonomyLevel,
  }) {
    return totalPrice * autonomyLevel.storePercent / 100.0;
  }

  /// Method to calculate the network's profit on a sale,
  /// given sale's total price and store's autonomy level
  double calculateNetworkProfit({
    required double totalPrice,
    required AutonomyLevel autonomyLevel,
  }) {
    return totalPrice * autonomyLevel.networkPercent / 100.0;
  }

  /// Method to get the network safety's profit on a sale,
  /// given sale's total price
  double calculateSafetyProfit({
    required double totalPrice,
    required AutonomyLevel autonomyLevel,
  }) {
    return totalPrice * safetyPercent / 100.0;
  }
}
