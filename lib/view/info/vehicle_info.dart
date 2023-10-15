import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../entities/vehicle.dart';
import '../../repositories/vehicle_image_repository.dart';
import '../../usecases/vehicle_image_use_case.dart';
import '../../utils/formats.dart';
import '../../utils/forms.dart';

/// Provider for vehicle info page
class VehicleInfoState with ChangeNotifier {
  /// Constructor
  VehicleInfoState({required this.vehicle}) {
    unawaited(init());
  }

  /// From which vehicle to show info
  final Vehicle vehicle;

  /// List of images of [vehicle]
  final images = <Future<File>>[];

  /// To load vehicle images
  final _vehicleImageUseCase = const VehicleImageUseCase(
    VehicleImageRepository(),
  );

  /// Initialize data
  Future<void> init() async {
    // Load images
    for (final vehicleImage in vehicle.images) {
      images.add(_vehicleImageUseCase.loadImage(vehicleImage.name));
    }
    notifyListeners();
  }
}

/// Widget to show detailed info about a [Vehicle]
class VehicleInfoPage extends StatelessWidget {
  /// Constructor
  const VehicleInfoPage({required this.vehicle, super.key});

  /// Vehicle object
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

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
      images = ChangeNotifierProvider<VehicleInfoState>(
        create: (context) {
          return VehicleInfoState(vehicle: vehicle);
        },
        child: Consumer<VehicleInfoState>(
          builder: (_, state, __) {
            return CarouselSlider.builder(
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
          },
        ),
      );
    }

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
  }
}
