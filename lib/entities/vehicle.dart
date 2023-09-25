import '../database/vehicle_table.dart';
import 'partner_store.dart';
import 'vehicle_image.dart';

/// Vehicle entity
class Vehicle {
  /// Constructor
  Vehicle({
    this.id,
    required this.storeId,
    required this.model,
    required this.brand,
    required this.modelYear,
    required this.fipePrice,
    required this.year,
    required this.plate,
    required this.purchaseDate,
  });

  /// ID for database identification
  int? id;

  /// Reference to [PartnerStore] in database
  final int storeId;

  /// Used to get info on Fipe API
  final String model;

  /// Used to get info on Fipe API
  final String brand;

  /// Model year, used on Fipe API
  final String modelYear;

  /// Price from Fipe API
  final double fipePrice;

  /// Manufacture year
  final int year;

  /// Plate, 7 chars in Brazilian format: AAA0A00
  final String plate;

  /// Date on which this vehicle was purchased by the [PartnerStore]
  final DateTime purchaseDate;

  /// List of all [VehicleImage]s for this vehicle
  final _images = <VehicleImage>[];

  /// Getter for list of [VehicleImage]s
  List<VehicleImage> get images => _images;

  /// Method to set vehicles
  set images(List<VehicleImage> items) {
    _images
      ..clear()
      ..addAll(items);
  }

  /// Map representation of [Vehicle]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[VehicleTable.id] = id;
    map[VehicleTable.storeId] = storeId;
    map[VehicleTable.model] = model;
    map[VehicleTable.brand] = brand;
    map[VehicleTable.year] = year;
    map[VehicleTable.modelYear] = modelYear;
    map[VehicleTable.plate] = plate;
    map[VehicleTable.fipePrice] = fipePrice;
    map[VehicleTable.purchaseDate] = purchaseDate.millisecondsSinceEpoch;

    return map;
  }
}
