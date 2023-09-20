import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/vehicle.dart';
import '../usecases/fipe_use_case.dart';
import 'form_utils.dart';

/// TODO: Utilize FipeUseCase on register vehicle form
/// TODO: Replace [TextEditingController]s with [DropdownButton]s
/// TODO: Make [FutureBuilder]s for each field to change when needed

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

  /// Controller for vehicle brand
  final TextEditingController brandController = TextEditingController();

  /// Controller for vehicle model
  final TextEditingController modelController = TextEditingController();

  /// Controller for vehicle manufacture year
  final TextEditingController manufactureYearController =
      TextEditingController();

  /// Controller for vehicle model year
  final TextEditingController modelYearController = TextEditingController();

  /// Controller for vehicle plate
  final TextEditingController plateController = TextEditingController();

  /// Input vehicle purchase date
  DateTime? purchaseDate;

  /// Method to set purchase date
  void setDate(DateTime date) {
    purchaseDate = date;

    // Update to show new picked date
    notifyListeners();
  }

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

    // TODO: Create vehicle with Fipe Code
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

/// Show invalid register dialog
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
