import 'dart:convert';

import 'package:http/http.dart' as http;

/// Use case for FIPE api requests
class FipeUseCase {
  /// Entry point for FIPE api
  static const String apiEntry = 'https://parallelum.com.br/fipe/api/v2';

  /// Vehicle type
  static const String vehicleType = 'cars';

  /// Vehicle brands route
  static const String brands = 'brands';

  /// Vehicle model route
  static const String models = 'models';

  /// Vehicle model year route
  static const String years = 'years';

  /// Method to get all brands from FIPE api
  Future<List<FipeBrand>?> getBrands() async {
    final url = Uri.parse('$apiEntry/$vehicleType/$brands');
    final response = await http.get(url);

    // Error
    if (response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body);
    final items = <FipeBrand>[];
    for (final item in json) {
      items.add(FipeBrand.fromJson(item));
    }

    return items;
  }

  /// Method to get all models by given brand
  Future<List<FipeModel>?> getModelsByBrand(int brandCode) async {
    final url = Uri.parse('$apiEntry/$vehicleType/$brands/$brandCode/$models');
    final response = await http.get(url);

    // Error
    if (response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body);
    final items = <FipeModel>[];
    for (final item in json) {
      items.add(FipeModel.fromJson(item));
    }

    return items;
  }

  /// Method to get all model years by given brand and model
  Future<List<FipeModelYear>?> getModelYears(
    int brandCode,
    int modelCode,
  ) async {
    final url = Uri.parse(
      '$apiEntry/$vehicleType/$brands'
      '/$brandCode/$models'
      '/$modelCode/$years',
    );
    final response = await http.get(url);

    // Error
    if (response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body);
    final items = <FipeModelYear>[];
    for (final item in json) {
      items.add(FipeModelYear.fromJson(item));
    }

    return items;
  }

  /// Method to get all extra info of a vehicle by given brand, model and year
  Future<List<FipeVehicleInfo>?> getInfoByModel(
    int brandCode,
    int modelCode,
    int yearCode,
  ) async {
    final url = Uri.parse(
      '$apiEntry'
      '/$vehicleType/$brands'
      '/$brandCode/$models'
      '/$modelCode/$years'
      '$yearCode',
    );
    final response = await http.get(url);

    // Error
    if (response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body);
    final items = <FipeVehicleInfo>[];
    for (final item in json) {
      items.add(
        FipeVehicleInfo.fromJson(item),
      );
    }

    return items;
  }
}

/// Wrapper for vehicle brand in FIPE api
class FipeBrand {
  /// Constructor
  FipeBrand({required this.code, required this.name});

  /// Constructor from json
  FipeBrand.fromJson(Map<String, dynamic> json)
      : code = int.parse(json['code']),
        name = json['name'];

  /// Brand code
  final int code;

  /// Brand name
  final String name;

  @override
  String toString() {
    return 'Code: $code, Name: $name';
  }
}

/// Wrapper for vehicle model in FIPE api
class FipeModel {
  /// Constructor
  FipeModel({required this.code, required this.name});

  /// Constructor from json
  FipeModel.fromJson(Map<String, dynamic> json)
      : code = int.parse(json['code']),
        name = json['name'];

  /// Model code
  final int code;

  /// Model name
  final String name;

  @override
  String toString() {
    return 'Code: $code, Name: $name';
  }
}

/// Wrappre for model year in FIPE api
class FipeModelYear {
  /// Constructor
  FipeModelYear({required this.code, required this.name});

  /// Constructor from json
  FipeModelYear.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        name = json['name'];

  /// Year code
  final String code;

  /// Year in readable form
  final String name;

  @override
  String toString() {
    return 'Code: $code, Name: $name';
  }
}

/// Wrapper for vehicle info in FIPE api
class FipeVehicleInfo {
  /// Constructor
  FipeVehicleInfo({
    required this.price,
    required this.brand,
    required this.model,
    required this.modelYear,
    required this.fuel,
    required this.fipeCode,
    required this.referenceMonth,
    required this.vehicleType,
    required this.fuelAcronym,
  });

  /// Constructor from JSON
  FipeVehicleInfo.fromJson(Map<String, dynamic> json)
      : price = double.parse(
          // To double
          json['price'] // JSON key
              .toString() // To string
              .substring(3) // Remove prefix R$
              .replaceAll('.', '') // Remove .
              .replaceAll(',', '.'), // Replace , with .
        ),
        brand = json['brand'],
        model = json['model'],
        modelYear = int.parse(json['modelYear']),
        fuel = json['fuel'],
        fipeCode = json['codeFipe'],
        referenceMonth = json['referenceMonth'],
        vehicleType = int.parse(json['vehicleType']),
        fuelAcronym = json['fuelAcronym'];

  /// Vehicle price
  final double price;

  /// Vehicle brand
  final String brand;

  /// Vehicle model
  final String model;

  /// Vehicle model year
  final int modelYear;

  /// Vehicle fuel type
  final String fuel;

  /// Vehicle FIPE code
  final String fipeCode;

  /// Vehicle reference month
  final String referenceMonth;

  /// Vehicle type code
  final int vehicleType;

  /// Vehicle fuel acronym
  final String fuelAcronym;

  @override
  String toString() {
    return 'VehicleType code: $vehicleType, brand: $brand, model: $model,'
        ' price: $price, Fipe code: $fipeCode, model year: $modelYear,'
        ' reference month: $referenceMonth, fuel: $fuel,'
        ' fuel acronym: $fuelAcronym';
  }
}
