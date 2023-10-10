import 'package:flutter/material.dart';

import '../../entities/vehicle.dart';

/// Widget to show detailed info about a [Vehicle]
class VehicleInfoPage extends StatelessWidget {
  /// Constructor
  const VehicleInfoPage({required this.vehicle, super.key});

  /// Vehicle object
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    // TODO: Show images, info and action button for /edit
    return Center(
      child: Text('Vehicle model: ${vehicle.model}'),
    );
  }
}
