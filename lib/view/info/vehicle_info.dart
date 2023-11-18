import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../entities/vehicle.dart';
import '../../repositories/vehicle_image_repository.dart';
import '../../repositories/vehicle_repository.dart';
import '../../usecases/vehicle_image_use_case.dart';
import '../../usecases/vehicle_use_case.dart';
import '../../utils/formats.dart';
import '../../utils/forms.dart';

/// Provider for vehicle info page
class VehicleInfoState with ChangeNotifier {
  /// Constructor
  VehicleInfoState({Vehicle? vehicle, this.vehicleId})
      : assert(vehicle != null || vehicleId != null) {
    unawaited(init(vehicle));
  }

  bool _loaded = false;

  /// Whether the vehicle has loaded or not
  bool get loaded => _loaded;

  /// From which vehicle to show info
  late final Vehicle? vehicle;

  /// Vehicle ID in case no [Vehicle] is passed
  final int? vehicleId;

  /// List of images of [vehicle]
  final images = <Future<File>>[];

  /// To load vehicle
  final _vehicleUseCase = const VehicleUseCase(VehicleRepository());

  /// To load vehicle images
  final _vehicleImageUseCase = const VehicleImageUseCase(
    VehicleImageRepository(),
  );

  /// Initialize data
  Future<void> init(Vehicle? vehicle) async {
    // Initialize vehicle
    if (vehicle != null) {
      this.vehicle = vehicle;
    } else {
      // Get vehicle from given id
      this.vehicle = await _vehicleUseCase.selectById(vehicleId!);
    }

    // Set loaded
    _loaded = true;

    // Only load images if the vehicle was found
    if (this.vehicle != null) {
      for (final vehicleImage in this.vehicle!.images) {
        images.add(_vehicleImageUseCase.loadImage(vehicleImage.name));
      }
    }
    notifyListeners();
  }
}

/// Widget to show detailed info about a [Vehicle]
class VehicleInfoPage extends StatelessWidget {
  /// Constructor
  const VehicleInfoPage({this.vehicle, this.vehicleId, super.key})
      : assert(vehicle != null || vehicleId != null);

  /// Vehicle object
  final Vehicle? vehicle;

  /// Vehicle id
  final int? vehicleId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.vehicleInfo),
      ),
      body: ChangeNotifierProvider<VehicleInfoState>(
        create: (context) {
          return VehicleInfoState(vehicle: vehicle, vehicleId: vehicleId);
        },
        child: Consumer<VehicleInfoState>(
          builder: (_, state, __) {
            // Check if still loading
            if (!state.loaded) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Get vehicle
            final vehicle = state.vehicle;

            // Check if vehicle was found
            if (vehicle == null) {
              return const Center(
                child: Text(
                  'Vehicle not found!',
                  style: TextStyle(fontSize: 25),
                ),
              );
            }

            // Load images
            final Widget images;
            if (vehicle.images.isEmpty) {
              images = Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  localization.noImages,
                  style: const TextStyle(fontSize: 25),
                ),
              );
            } else {
              images = CarouselSlider.builder(
                itemCount: vehicle.images.length,
                itemBuilder: (context, index, realIndex) {
                  final width = MediaQuery.of(context).size.width;

                  return FutureBuilder(
                    future: state.images[index],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.data == null) {
                        return Text(localization.imageLoadFailed);
                      }

                      return Image.file(
                        snapshot.data!,
                        width: width,
                        fit: BoxFit.contain,
                      );
                    },
                  );
                },
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  autoPlay: true,
                  enableInfiniteScroll: false,
                ),
              );
            }

            // Build main widget
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextHeader(label: localization.images),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: images,
                ),
                TextHeader(label: localization.brand),
                InfoText(vehicle.brand),
                TextHeader(label: localization.model),
                InfoText(vehicle.model),
                TextHeader(label: localization.modelYear),
                InfoText(vehicle.modelYear),
                TextHeader(label: localization.manufactureYear),
                InfoText(vehicle.year.toString()),
                TextHeader(label: localization.fipePrice),
                InfoText(formatPrice(vehicle.fipePrice)),
                TextHeader(label: localization.purchasePrice),
                InfoText(formatPrice(vehicle.purchasePrice)),
                TextHeader(label: localization.purchaseDate),
                InfoText(formatDate(vehicle.purchaseDate)),
                TextHeader(label: localization.soldYet),
                InfoText(vehicle.sold ? localization.yes : localization.no),
                TextHeader(label: localization.plate),
                InfoText(vehicle.plate),
              ],
            );
          },
        ),
      ),
    );
  }
}
