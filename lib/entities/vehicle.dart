import '../database/vehicle_table.dart';
import 'partner_store.dart';
import 'vehicle_image.dart';

/// Vehicle entity
class Vehicle {
  /// Constructor
  Vehicle({
    this.id,
    required this.storeId,
    required this.modelId,
    required this.brandId,
    required this.yearId,
    required this.modelYear,
    required this.vehicleImage,
    required this.plate,
    required this.price,
    required this.purchaseDate,
  });

  /// ID for database identification
  final int? id;

  /// Reference to [PartnerStore] in database
  final int storeId;

  /// Used to get info on Fipe API
  final int modelId;

  /// Used to get info on Fipe API
  final int brandId;

  /// Manufacture year, used on Fipe API
  final String yearId;

  /// Model year
  final int modelYear;

  /// List of all [VehicleImage]s for this vehicle
  final _images = <VehicleImage>[];

  /// Getter for list of [VehicleImage]s
  List<VehicleImage> get images => List.unmodifiable(_images);

  /// Method to set vehicles
  set images(List<VehicleImage> items) {
    _images
      ..clear()
      ..addAll(items);
  }

  /// Name of image file for this vehicle
  final String vehicleImage;

  /// Plate, 7 chars in Brazilian format: AAA0A00
  final String plate;

  /// Vehicle price
  final double price;

  /// Date on which this vehicle was purchased by the [PartnerStore]
  final DateTime purchaseDate;

  /// Map representation of [Vehicle]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[VehicleTable.id] = id;
    map[VehicleTable.storeId] = storeId;
    map[VehicleTable.modelId] = modelId;
    map[VehicleTable.brandId] = brandId;
    map[VehicleTable.yearId] = yearId;
    map[VehicleTable.modelYear] = modelYear;
    map[VehicleTable.vehicleImage] = vehicleImage;
    map[VehicleTable.plate] = plate;
    map[VehicleTable.price] = price;
    map[VehicleTable.purchaseDate] = purchaseDate.millisecondsSinceEpoch;

    return map;
  }
}
