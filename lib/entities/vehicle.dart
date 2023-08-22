import 'partner_store.dart';

/// Vehicle class
class Vehicle {
  /// Constructor
  Vehicle({
    required this.id,
    required this.storeId,
    required this.modelId,
    required this.brandId,
    required this.creationYear,
    required this.vehicleYear,
    required this.vehicleImage,
    required this.plate,
    required this.price,
    required this.purchaseDate,
  });

  /// ID for database identification
  final int id;

  /// Reference to [PartnerStore] in database
  final int storeId;

  /// Used to get info on Fipe API
  final int modelId;

  /// Used to get info on Fipe API
  final int brandId;

  /// ANO DE FABRICAÇÃO VS ANO MODELO
  final int creationYear;
  final int vehicleYear;

  /// Name of image file for this vehicle
  final String vehicleImage;

  /// Plate, 7 chars in Brazilian format: AAA0A00
  final String plate;

  /// Vehicle price
  final double price;

  final DateTime purchaseDate;
}
