import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../entities/vehicle.dart';
import '../entities/vehicle_image.dart';
import '../repositories/local_image_repository.dart';
import '../usecases/fipe_use_case.dart';
import 'form_utils.dart';

/// Provider for register vehicle page
class RegisterVehicleState with ChangeNotifier {
  /// Constructor
  RegisterVehicleState({this.onRegister}) {
    init();
  }

  /// Callback function for when a vehicle gets registered
  final void Function()? onRegister;

  /// Operations on FIPE api
  final FipeUseCase fipeUseCase = FipeUseCase();

  /// To save [VehicleImage]s
  final LocalImageRepository _localImageRepository =
      const LocalImageRepository();

  /// List of vehicle brands
  late Future<List<FipeBrand>?> brands;

  /// List of models
  late Future<List<FipeModel>?> models;

  /// List of model years
  late Future<List<FipeModelYear>?> modelYears;

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

    // Reset lists
    models = Future.value(null);
    modelYears = Future.value(null);

    // Reset current info
    _currentBrand = null;
    _currentModel = null;
    _currentModelYear = null;
    currentVehicleInfo = null;
  }

  /// Method to add images using [ImagePicker]
  Future<void> addImages() async {
    try {
      // Wait for picked images
      final images = await ImagePicker().pickMultiImage();

      // Add to list of image paths
      for (final file in images) {
        _localImageRepository.saveImage(File(file.path));
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
    currentVehicleInfo = null;

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
    currentVehicleInfo = null;

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
  Future<String> register() async {
    return 'Not implemented';
  }
}

/// Form for [Vehicle] registering
class RegisterVehicleForm extends StatelessWidget {
  /// Constructor
  const RegisterVehicleForm({this.onRegister, super.key});

  /// Callback function for when a vehicle gets registered
  final void Function()? onRegister;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterVehicleState>(
      create: (context) {
        return RegisterVehicleState(onRegister: onRegister);
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
                        registerDialog(context, result);
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
void registerDialog(BuildContext context, String? result) {
  showDialog(
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
