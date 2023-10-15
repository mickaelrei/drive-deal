import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../entities/vehicle.dart';
import '../../repositories/vehicle_image_repository.dart';
import '../../repositories/vehicle_repository.dart';
import '../../usecases/fipe_use_case.dart';
import '../../usecases/vehicle_image_use_case.dart';
import '../../usecases/vehicle_use_case.dart';
import '../../utils/dialogs.dart';
import '../../utils/formats.dart';
import '../../utils/forms.dart';

/// Provider for vehicle edit page
class VehicleEditState with ChangeNotifier {
  /// Constructor
  VehicleEditState({required this.vehicle, this.onEdit}) {
    // Set initial values on inputs
    unawaited(init());
  }

  /// What [Vehicle] is this provider linked to
  final Vehicle vehicle;

  /// Callback function for when a vehicle gets edited
  final void Function(Vehicle)? onEdit;

  final _formKey = GlobalKey<FormState>();

  /// Form key getter
  GlobalKey<FormState> get formKey => _formKey;

  /// Whether the vehicle infos are still being loaded or not
  bool loading = true;

  /// Whether there was an error while loading vehicle info
  bool error = false;

  /// Operations on FIPE api
  final fipeUseCase = FipeUseCase();

  /// Operations on [Vehicle] database table
  final _vehicleUseCase = const VehicleUseCase(
    VehicleRepository(),
  );

  /// To load/save images
  final _vehicleImageUseCase = const VehicleImageUseCase(
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
  final manufactureYearController = TextEditingController();

  /// Controller for vehicle plate
  final plateController = TextEditingController();

  /// Controller for vehicle purchase price
  final purchasePriceController = TextEditingController();

  /// Input vehicle purchase date
  DateTime? purchaseDate;

  bool _disposed = false;

  /// Initialize inputs with current vehicle data
  Future<void> init() async {
    // Clear lists
    clear();

    // Set controllers
    plateController.text = vehicle.plate;
    manufactureYearController.text = vehicle.year.toString();
    purchasePriceController.text = vehicle.purchasePrice.toString();
    purchaseDate = vehicle.purchaseDate;

    brands = fipeUseCase.getBrands();

    // Get brand
    _currentBrand = await fipeUseCase.getBrandByName(vehicle.brand);
    if (_currentBrand == null) {
      // Error getting brand
      error = true;
      loading = false;
      _updateScreen();
      return;
    }

    // Get model
    _currentModel = await fipeUseCase.getModelByName(
      vehicle.model,
      _currentBrand!,
    );
    if (_currentModel == null) {
      // Error getting model
      error = true;
      loading = false;
      _updateScreen();
      return;
    }

    // Get model year
    _currentModelYear = await fipeUseCase.getModelYearByName(
      vehicle.modelYear,
      _currentBrand!,
      _currentModel!,
    );
    if (_currentModelYear == null) {
      // Error getting model year
      error = true;
      loading = false;
      _updateScreen();
      return;
    }

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

    // Finished loading
    loading = false;
    _updateScreen();
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
    purchasePriceController.clear();
    purchaseDate = null;

    // Reset list of images
    imagePaths.clear();

    _updateScreen();
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
      _updateScreen();
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
      _updateScreen();
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
      _updateScreen();
    }
  }

  /// Method to set purchase date
  void setDate(DateTime date) {
    purchaseDate = date;

    // Update to show new picked date
    _updateScreen();
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
    _updateScreen();
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
  Future<String?> edit(BuildContext context) async {
    final localization = AppLocalizations.of(context)!;

    // Check if this vehicle is already sold
    if (vehicle.sold) {
      return localization.alreadySold;
    }
    // Check if all inputs are set
    if (_currentBrand == null) {
      return localization.chooseBrand;
    }
    if (_currentModel == null) {
      return localization.chooseModel;
    }
    if (_currentModelYear == null) {
      return localization.chooseModelYear;
    }
    if (currentVehicleInfo == null) {
      return localization.noVehicleInfo;
    }

    // Check if manufacture year input is a valid number
    final manufactureYear = int.tryParse(manufactureYearController.text);
    if (manufactureYear == null) {
      return localization.invalidManufactureYear;
    }

    // Check if plate is in valid format
    final plate = plateController.text.toUpperCase();
    final plateRegex = RegExp(r'[A-Z]{3}\d[A-Z]\d{2}');
    if (!plateRegex.hasMatch(plate)) {
      return localization.invalidPlate;
    }

    // Check for purchase date
    if (purchaseDate == null) {
      return localization.choosePurchaseDate;
    }

    // Check for purchase price
    final purchasePrice = double.tryParse(purchasePriceController.text);
    if (purchasePrice == null || purchasePrice < 0) {
      return localization.invalidPrice;
    }

    // Get price
    final vehicleInfo = await currentVehicleInfo;
    if (vehicleInfo == null) {
      return localization.loadingVehicleDataError;
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
    vehicle.purchasePrice = purchasePrice;

    // Update in database
    await _vehicleUseCase.update(vehicle, imagePaths);

    // Call onEdit callback
    if (onEdit != null) {
      onEdit!(vehicle);
    }

    // Success
    return null;
  }

  void _updateScreen() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
    manufactureYearController.dispose();
    plateController.dispose();
    purchasePriceController.dispose();
  }
}

/// Form for [Vehicle] editing
class VehicleEditForm extends StatelessWidget {
  /// Constructor
  const VehicleEditForm({required this.vehicle, this.onEdit, super.key});

  /// Which [Vehicle] will be edited
  final Vehicle vehicle;

  /// Callback function for when the vehicle gets edited
  final void Function(Vehicle)? onEdit;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<VehicleEditState>(
      create: (context) {
        return VehicleEditState(
          vehicle: vehicle,
          onEdit: onEdit,
        );
      },
      child: Consumer<VehicleEditState>(
        builder: (_, state, __) {
          // If still loading info
          if (state.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator.adaptive(),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      localization.loading,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
            );
          }

          // If an error occured while loading
          if (state.error) {
            return Center(
              child: Text(
                localization.loadingVehicleDataError,
                style: const TextStyle(fontSize: 17),
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

          return Form(
            key: state.formKey,
            child: ListView(
              children: [
                FormTitle(title: localization.edit),
                TextHeader(label: localization.brand),
                FutureDropdown<FipeBrand>(
                  initialSelected: state._currentBrand,
                  future: state.brands,
                  onChanged: state.setBrand,
                  dropdownBuilder: (item) {
                    return Text(item.name);
                  },
                ),
                TextHeader(label: localization.model),
                FutureDropdown<FipeModel>(
                  initialSelected: state._currentModel,
                  future: state.models,
                  onChanged: state.setModel,
                  dropdownBuilder: (item) {
                    return Text(item.name);
                  },
                ),
                TextHeader(label: localization.modelYear),
                FutureDropdown<FipeModelYear>(
                  initialSelected: state._currentModelYear,
                  future: state.modelYears,
                  onChanged: state.setModelYear,
                  dropdownBuilder: (item) {
                    return Text(item.name);
                  },
                ),
                TextHeader(label: localization.fipePrice),
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
                TextHeader(label: localization.purchasePrice),
                FormTextEntry(
                  label: localization.purchasePrice,
                  controller: state.purchasePriceController,
                ),
                TextHeader(label: localization.manufactureYear),
                FormTextEntry(
                  label: localization.manufactureYear,
                  controller: state.manufactureYearController,
                ),
                TextHeader(label: localization.plate),
                FormTextEntry(
                  label: localization.plate,
                  controller: state.plateController,
                ),
                TextHeader(label: localization.purchaseDate),
                DatePicker(
                  hintText: localization.purchaseDate,
                  initialDate: state.purchaseDate,
                  onDatePicked: state.setDate,
                ),
                TextHeader(label: localization.images),
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
                    label: localization.edit,
                    onPressed: () async {
                      // Validate inputs
                      if (!state.formKey.currentState!.validate()) return;

                      // Try editing
                      final result = await state.edit(context);

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
