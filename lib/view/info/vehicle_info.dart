import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
    // Load images
    final Widget images;
    if (vehicle.images.isEmpty) {
      images = const Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Text(
          'No images!',
          style: TextStyle(fontSize: 25),
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
                      return const Text('Failed to load image');
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
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: TextHeader(label: 'Images'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: images,
        ),
        const TextHeader(label: 'Brand'),
        InfoText(vehicle.brand),
        const TextHeader(label: 'Model'),
        InfoText(vehicle.model),
        const TextHeader(label: 'Model year'),
        InfoText(vehicle.modelYear),
        const TextHeader(label: 'Manufacture year'),
        InfoText(vehicle.year.toString()),
        const TextHeader(label: 'FIPE price'),
        InfoText(formatPrice(vehicle.fipePrice)),
        const TextHeader(label: 'Purchase price'),
        InfoText(formatPrice(vehicle.purchasePrice)),
        const TextHeader(label: 'Purchase date'),
        InfoText(formatDate(vehicle.purchaseDate)),
        const TextHeader(label: 'Sold yet'),
        InfoText(vehicle.sold ? 'Yes' : 'No'),
        const TextHeader(label: 'Plate'),
        InfoText(vehicle.plate),
      ],
    );
  }
}
