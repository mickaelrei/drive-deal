import 'partner_store.dart';

/// Sale class
class Sale {
  /// Constructor
  Sale({
    required this.id,
    required this.storeId,
    required this.clientCpf,
    required this.clientName,
    required this.saleDate,
    required this.price,
  });

  /// ID for database identification
  final int id;

  /// For PartnerStore reference in database
  final int storeId;

  /// CPF of client
  final String clientCpf;

  /// Name of client
  final String clientName;

  /// On what date the sale happened
  final DateTime saleDate;

  /// Price of sale
  final double price;

  /// Get [PartnerStore]'s profit on this sale
  Future<double> getStoreProfit() async {
    return 0;
  }

  /// Get network's profit on this sale
  Future<double> getNetworkProfit() async {
    return 0;
  }

  /// Get network's safety profit on this sale
  Future<double> getSafetyProfit() async {
    return 0;
  }
}
