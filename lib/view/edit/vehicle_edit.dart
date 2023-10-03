import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../entities/vehicle.dart';
import '../../repositories/vehicle_image_repository.dart';
import '../../repositories/vehicle_repository.dart';
import '../../usecases/fipe_use_case.dart';
import '../../usecases/vehicle_image_use_case.dart';
import '../../usecases/vehicle_use_case.dart';
import '../form_utils.dart';

/// Provider for edit vehicle page
class EditVehicleState with ChangeNotifier {
  /// Constructor
  EditVehicleState({required this.vehicle, this.onEdit}) {
    // Set initial values on inputs
    unawaited(init());
  }

  /// What [Vehicle] is this provider linked to
  final Vehicle vehicle;

  /// Callback function for when a vehicle gets edited
  final void Function(Vehicle)? onEdit;

  /// Whether the vehicle infos are still being loaded or not
  bool loading = true;

  /// Whether there was an error while loading vehicle info
  bool error = false;

  /// Operations on FIPE api
  final FipeUseCase fipeUseCase = FipeUseCase();

  /// Operations on [Vehicle] database table
  final VehicleUseCase _vehicleUseCase = const VehicleUseCase(
    VehicleRepository(),
  );

  /// To load/save images
  final VehicleImageUseCase _vehicleImageUseCase = const VehicleImageUseCase(
    VehicleImageRepository(),
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

  /// Initialize inputs with current vehicle data
  Future<void> init() async {
    // Clear lists
    clear();

    // Set controllers
    plateController.text = vehicle.plate;
    manufactureYearController.text = vehicle.year.toString();
    purchaseDate = vehicle.purchaseDate;

    brands = fipeUseCase.getBrands();

    // Get brand
    _currentBrand = await fipeUseCase.getBrandByName(vehicle.brand);
    if (_currentBrand == null) {
      // Error getting brand
      log('Error loading brand ${vehicle.brand}');
      error = true;
      loading = false;
      notifyListeners();
      return;
    }
    log('Loaded brand');

    // Get model
    _currentModel = await fipeUseCase.getModelByName(
      vehicle.model,
      _currentBrand!,
    );
    if (_currentModel == null) {
      // Error getting model
      log('Error loading model ${vehicle.model}');
      error = true;
      loading = false;
      notifyListeners();
      return;
    }
    log('Loaded model');

    // Get model year
    _currentModelYear = await fipeUseCase.getModelYearByName(
      vehicle.modelYear,
      _currentBrand!,
      _currentModel!,
    );
    if (_currentModelYear == null) {
      // Error getting model year
      log('Error loading model year ${vehicle.modelYear}');
      error = true;
      loading = false;
      notifyListeners();
      return;
    }
    log('Loaded model year');

    // Get fipe price
    currentVehicleInfo = fipeUseCase.getInfoByModel(
      _currentBrand!,
      _currentModel!,
      _currentModelYear!,
    );

    // Set list of Fipe info for dropdowns
    models = fipeUseCase.getModelsByBrand(_currentBrand!);
    modelYears = fipeUseCase.getModelYears(_currentBrand!, _currentModel!);

    // Set list of images
    for (final image in vehicle.images) {
      final file = await _vehicleImageUseCase.loadImage(image.name);
      imagePaths.add(file.path);
    }
    log('Loaded images');

    // Finished loading
    loading = false;
    notifyListeners();
  }

  /// Method to clear everything for a new edit
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

  /// Method to try editing a vehicle
  Future<String?> edit() async {
    // Check if this vehicle is already sold
    if (vehicle.sold) {
      return 'This vehicle was already sold. No permission to make edits on it';
    }
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
    final fipePrice = vehicleInfo.price;

    // Update info on vehicle object
    vehicle.brand = _currentBrand!.name;
    vehicle.model = _currentModel!.name;
    vehicle.modelYear = _currentModelYear!.name;
    vehicle.fipePrice = fipePrice;
    vehicle.year = manufactureYear;
    vehicle.plate = plate;
    vehicle.purchaseDate = purchaseDate!;

    // Update in database
    await _vehicleUseCase.update(vehicle, imagePaths);

    // Call onEdit callback
    if (onEdit != null) {
      onEdit!(vehicle);
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

/// Form for [Vehicle] editing
class EditVehicleForm extends StatelessWidget {
  /// Constructor
  const EditVehicleForm({required this.vehicle, this.onEdit, super.key});

  /// Which [Vehicle] will be edited
  final Vehicle vehicle;

  /// Callback function for when the vehicle gets edited
  final void Function(Vehicle)? onEdit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditVehicleState>(
      create: (context) {
        return EditVehicleState(
          vehicle: vehicle,
          onEdit: onEdit,
        );
      },
      child: Consumer<EditVehicleState>(
        builder: (_, state, __) {
          // If still loading info
          if (state.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator.adaptive(),
                  Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      'Loading vehicle data...',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
            );
          }

          // If an error occured while loading
          if (state.error) {
            return const Center(
              child: Text(
                'Error loading vehicle data. Try again later',
                style: TextStyle(fontSize: 17),
              ),
            );
          }

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
                  title: 'Edit Vehicle',
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
                  initialSelected: state._currentModel,
                  future: state.models,
                  onChanged: state.setModel,
                  dropdownBuilder: (item) {
                    return Text(item.name);
                  },
                ),
                const FormTextHeader(label: 'Model year'),
                FutureDropdown<FipeModelYear>(
                  initialSelected: state._currentModelYear,
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
                    label: 'Edit',
                    onPressed: () async {
                      // Try editing
                      final result = await state.edit();

                      // Show dialog with edit result
                      if (context.mounted) {
                        await editDialog(context, result);
                      }

                      // Exit from edit page
                      if (result == null) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
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

/// Show edit dialog
Future<void> editDialog(BuildContext context, String? result) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(result == null ? 'Success' : 'Error'),
        content: Text(result ?? 'Successfully edited!'),
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
