import 'dart:async';
import 'dart:io';

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
    unawaited(init());
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
  Future<void> init() async {
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

    // Reset list of images
    imagePaths.clear();

    notifyListeners();
  }

  /// Method to add images from gallery using [ImagePicker]
  Future<void> addImagesFromGallery() async {
    try {
      // Wait for picked images
      final images = await ImagePicker().pickMultiImage();

      // Add to list of image paths
      for (final file in images) {
        if (imagePaths.contains(file.path)) continue;

        imagePaths.add(file.path);
      }
      notifyListeners();
    } on PlatformException {
      /// Happens when trying to use ImagePicker while already being used
      /// (usually on a double click from the user)
    }
  }

  /// Method to add an image from camera using [ImagePicker]
  Future<void> addImageFromCamera() async {
    try {
      // Wait for picked image
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      // Check if image is already in list
      if (imagePaths.contains(image.path)) return;

      // Add to list of image paths
      imagePaths.add(image.path);
      notifyListeners();
    } on PlatformException {
      /// Happens when trying to use ImagePicker while already being used
      /// (usually on a double click from the user)
    }
  }

  /// Method to remove an image
  void removeImage(String path) {
    // Check if exists
    if (imagePaths.contains(path)) {
      imagePaths.remove(path);
      notifyListeners();
    }
  }

  /// Method to set purchase date
  void setDate(DateTime date) {
    purchaseDate = date;

    // Update to show new picked date
    notifyListeners();
  }

  /// Method to set new chosen brand
  Future<void> setBrand(FipeBrand? brand) async {
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
  Future<void> setModel(FipeModel? model) async {
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
  Future<void> setModelYear(FipeModelYear? modelYear) async {
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
      sold: false,
    );
    await _vehicleUseCase.insert(vehicle, imagePaths);

    // Call onRegister callback
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
          // Create preview images
          final previewImages = <Widget>[];
          for (final path in state.imagePaths) {
            previewImages.add(Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: VehicleImagePreview(
                imagePath: path,
                onDelete: () {
                  state.removeImage(path);
                },
              ),
            ));
          }

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
                const FormTextHeader(label: 'Model year'),
                FutureDropdown<FipeModelYear>(
                  future: state.modelYears,
                  onChanged: state.setModelYear,
                  dropdownBuilder: (item) {
                    return Text(item.name);
                  },
                ),
                const FormTextHeader(label: 'FIPE price'),
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
                      return const FormTextEntry(
                        enabled: false,
                      );
                    }

                    return FormTextEntry(
                      text: formatPrice(snapshot.data!.price),
                      enabled: false,
                    );
                  },
                ),
                const FormTextHeader(label: 'Manufacture year'),
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
                  child: VehicleImagesScrollView(
                    addFromCamera: state.addImageFromCamera,
                    addFromGallery: state.addImagesFromGallery,
                    previewImages: previewImages,
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

/// Widget for a scrollable with preview of vehicle images
class VehicleImagesScrollView extends StatelessWidget {
  /// Constructor
  const VehicleImagesScrollView({
    required this.addFromGallery,
    required this.addFromCamera,
    required this.previewImages,
    super.key,
  });

  /// Callback to add images from gallery
  final void Function() addFromGallery;

  /// Callback to add image from camera
  final void Function() addFromCamera;

  /// List of preview images
  final List<Widget> previewImages;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 33,
              child: IconButton(
                color: Colors.white,
                iconSize: 37,
                splashRadius: 30,
                onPressed: addFromGallery,
                icon: const Icon(
                  Icons.image,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 33,
              child: IconButton(
                color: Colors.white,
                iconSize: 37,
                splashRadius: 30,
                onPressed: addFromCamera,
                icon: const Icon(
                  Icons.camera_alt,
                ),
              ),
            ),
          ),
          ...previewImages,
        ],
      ),
    );
  }
}

/// Widget for displaying a preview of a vehicle image
class VehicleImagePreview extends StatelessWidget {
  /// Constructor
  const VehicleImagePreview({
    required this.imagePath,
    this.onDelete,
    super.key,
  });

  /// Path to image
  final String imagePath;

  /// Optional callback for delete button click
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
      ),
      color: Colors.lightBlue[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: FileImage(
                File(imagePath),
              ),
            ),
            IconButton(
              splashRadius: 25,
              splashColor: Colors.grey,
              color: Colors.grey[700],
              onPressed: onDelete,
              icon: const Icon(Icons.delete, size: 35),
            )
          ],
        ),
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
