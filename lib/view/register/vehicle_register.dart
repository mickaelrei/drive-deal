import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../entities/vehicle.dart';
import '../../repositories/vehicle_repository.dart';
import '../../usecases/fipe_use_case.dart';
import '../../usecases/vehicle_use_case.dart';
import '../form_utils.dart';

/// Provider for register vehicle page
class RegisterVehicleState with ChangeNotifier {
  /// Constructor
  RegisterVehicleState({required this.partnerStore, this.onRegister}) {
    init();
  }

  /// What [PartnerStore] is this provider linked to
  final PartnerStore partnerStore;

  /// Callback function for when a vehicle gets registered
  final void Function(Vehicle)? onRegister;

  /// Operations on FIPE api
  final FipeUseCase fipeUseCase = FipeUseCase();

  /// Operations on [Vehicle] database table
  final VehicleUseCase _vehicleUseCase = const VehicleUseCase(
    VehicleRepository(),
  );

  /// List of path of images to be linked to the [Vehicle]
  final imagePaths = <String>[];

  /// List of vehicle brands
  late Future<List<FipeBrand>?> brands;

  /// List of models
  late Future<List<FipeModel>?>? models;

  /// List of model years
  late Future<List<FipeModelYear>?>? modelYears;

  /// Currently chosen info
  FipeBrand? _currentBrand;
  FipeModel? _currentModel;
  FipeModelYear? _currentModelYear;

  /// Info about currently chosen vehicle
  Future<FipeVehicleInfo?>? currentVehicleInfo;

  /// Controller for vehicle manufacture year
  final TextEditingController manufactureYearController =
      TextEditingController();

  /// Controller for vehicle plate
  final TextEditingController plateController = TextEditingController();

  /// Input vehicle purchase date
  DateTime? purchaseDate;

  /// Initialize some lists
  void init() {
    brands = fipeUseCase.getBrands();
    clear();
  }

  /// Method to clear everything for a new register
  void clear() {
    // Reset lists
    models = null;
    modelYears = null;

    // Reset current info
    _currentBrand = null;
    _currentModel = null;
    _currentModelYear = null;
    currentVehicleInfo = Future.value(null);

    // Reset dropdown lists
    models = Future.value(null);
    modelYears = Future.value(null);

    // Reset controllers
    manufactureYearController.clear();
    plateController.clear();
    purchaseDate = null;

    notifyListeners();
  }

  /// Method to add images using [ImagePicker]
  Future<void> addImages() async {
    try {
      // Wait for picked images
      final images = await ImagePicker().pickMultiImage();

      // Add to list of image paths
      for (final file in images) {
        if (imagePaths.contains(file.path)) continue;

        imagePaths.add(file.path);
      }
    } on PlatformException {
      /// Happens when trying to use ImagePicker while already being used
      /// (usually on a double click from the user)
    }
  }

  /// Method to set purchase date
  void setDate(DateTime date) {
    purchaseDate = date;

    // Update to show new picked date
    notifyListeners();
  }

  /// Method to set new chosen brand
  void setBrand(FipeBrand? brand) {
    if (brand == null || _currentBrand == brand) {
      return;
    }

    // Update list of models
    models = fipeUseCase.getModelsByBrand(brand);

    // Update lists
    modelYears = Future.value(null);

    // Update current info
    _currentBrand = brand;
    _currentModel = null;
    _currentModelYear = null;
    currentVehicleInfo = Future.value(null);

    // Update screen
    notifyListeners();
  }

  /// Method to set new chosen model
  void setModel(FipeModel? model) {
    if (model == null || _currentModel == model) {
      return;
    }

    if (_currentBrand == null) {
      return;
    }

    // Update list of model years
    modelYears = fipeUseCase.getModelYears(_currentBrand!, model);

    // Update current info
    _currentModel = model;
    _currentModelYear = null;
    currentVehicleInfo = Future.value(null);

    // Update screen
    notifyListeners();
  }

  /// Method to set new chosen model year
  void setModelYear(FipeModelYear? modelYear) {
    if (modelYear == null || _currentModelYear == modelYear) {
      return;
    }

    if (_currentBrand == null || _currentModel == null) {
      return;
    }

    // Update current info
    _currentModelYear = modelYear;

    // Update current vehicle info
    currentVehicleInfo = fipeUseCase.getInfoByModel(
      _currentBrand!,
      _currentModel!,
      _currentModelYear!,
    );

    // Update screen
    notifyListeners();
  }

  /// Method to set new chosen plate
  void setPlate(String plate) {
    // TODO: idk
  }

  /// Method to try registering a vehicle
  Future<String?> register() async {
    // Check if all inputs are set
    if (_currentBrand == null) {
      return 'Choose a brand';
    }
    if (_currentModel == null) {
      return 'Choose a model';
    }
    if (_currentModelYear == null) {
      return 'Choose a model year';
    }
    if (currentVehicleInfo == null) {
      return 'Vehicle info not retrieved yet. Try again';
    }

    // Check if manufacture year input is a valid number
    final manufactureYear = int.tryParse(manufactureYearController.text);
    if (manufactureYear == null) {
      return 'Manufacture year must be a valid number';
    }

    // Check if plate is in valid format
    final plate = plateController.text.toUpperCase();
    final plateRegex = RegExp(r'[A-Z]{3}\d[A-Z]\d{2}');
    if (!plateRegex.hasMatch(plate)) {
      return 'Plate needs to be in AAA0A00 format';
    }

    // Check for purchase date
    if (purchaseDate == null) {
      return 'Choose a purchase date';
    }

    // Get price
    final vehicleInfo = await currentVehicleInfo;
    if (vehicleInfo == null) {
      return 'No vehicle info. Try again later';
    }
    final currentPrice = vehicleInfo.price;

    // Create vehicle object and insert into database
    final vehicle = Vehicle(
      storeId: partnerStore.id!,
      model: _currentModel!.name,
      brand: _currentBrand!.name,
      modelYear: _currentModelYear!.name,
      fipePrice: currentPrice,
      year: manufactureYear,
      plate: plate,
      purchaseDate: purchaseDate!,
    );
    final vehicleId = await _vehicleUseCase.insert(vehicle, imagePaths);

    // Set id
    vehicle.id = vehicleId;
    if (onRegister != null) {
      onRegister!(vehicle);
    }

    // Success
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    manufactureYearController.dispose();
    plateController.dispose();
  }
}

/// Form for [Vehicle] registering
class RegisterVehicleForm extends StatelessWidget {
  /// Constructor
  const RegisterVehicleForm(
      {required this.partnerStore, this.onRegister, super.key});

  /// Which [PartnerStore] will the registered vehicle be linked to
  final PartnerStore partnerStore;

  /// Callback function for when a vehicle gets registered
  final void Function(Vehicle)? onRegister;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterVehicleState>(
      create: (context) {
        return RegisterVehicleState(
          partnerStore: partnerStore,
          onRegister: onRegister,
        );
      },
      child: Consumer<RegisterVehicleState>(
        builder: (_, state, __) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FormTitle(
                  title: 'Register Vehicle',
                ),
                const FormTextHeader(label: 'Brand'),
                FutureDropdown<FipeBrand>(
                  initialSelected: state._currentBrand,
                  future: state.brands,
                  onChanged: state.setBrand,
                  dropdownBuilder: (item) {
                    return Text(item.name);
                  },
                ),
                const FormTextHeader(label: 'Model'),
                FutureDropdown<FipeModel>(
                  future: state.models,
                  onChanged: state.setModel,
                  dropdownBuilder: (item) {
                    return Text(item.name);
                  },
                ),
                const FormTextHeader(label: 'Model Year'),
                FutureDropdown<FipeModelYear>(
                  future: state.modelYears,
                  onChanged: state.setModelYear,
                  dropdownBuilder: (item) {
                    return Text(item.name);
                  },
                ),
                const FormTextHeader(label: 'FIPE Price'),
                FutureBuilder(
                  future: state.currentVehicleInfo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 12.0,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.data == null) {
                      // Empty text entry
                      return const FormTextEntry();
                    }

                    return FormTextEntry(
                      text: formatPrice(snapshot.data!.price),
                      enabled: false,
                    );
                  },
                ),
                const FormTextHeader(label: 'Manufacture Year'),
                FormTextEntry(
                  label: 'Manufacture year',
                  controller: state.manufactureYearController,
                ),
                const FormTextHeader(label: 'Plate'),
                FormTextEntry(
                  label: 'Plate',
                  controller: state.plateController,
                ),
                const FormTextHeader(label: 'Purchase date'),
                DatePicker(
                  initialDate: state.purchaseDate,
                  onDatePicked: state.setDate,
                ),
                const FormTextHeader(label: 'Images'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: state.addImages,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        hintText: 'Add images',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Add images',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SubmitButton(
                    label: 'Register',
                    onPressed: () async {
                      // Try registering
                      final result = await state.register();

                      // Show dialog with register result
                      if (context.mounted) {
                        await registerDialog(context, result);
                      }

                      // Clear inputs
                      if (result == null) {
                        state.clear();
                      }
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Format price in brazil's currency
String formatPrice(double price) {
  final priceFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  return priceFormat.format(price);
}

/// Show register dialog
Future<void> registerDialog(BuildContext context, String? result) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(result == null ? 'Success' : 'Error'),
        content: Text(result ?? 'Successfully registered!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          )
        ],
      );
    },
  );
}
