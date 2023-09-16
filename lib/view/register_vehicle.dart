import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/vehicle.dart';
import 'form_utils.dart';

/// Provider for register vehicle page
class RegisterVehicleState with ChangeNotifier {
  /// Constructor
  RegisterVehicleState({this.onRegister});

  /// Callback function for when a vehicle gets registered
  final void Function()? onRegister;

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

  /// Method to try registering a vehicle
  Future<String> register() async {
    print('Trying vehicle register');

    return 'Not implemented';
  }

  /// Method to get String form of date
  String getDateString(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Page for registering a [Vehicle]
class RegisterVehiclePage extends StatelessWidget {
  /// Constructor
  const RegisterVehiclePage({this.onRegister, super.key});

  /// Callback function for when a vehicle gets registered
  final void Function()? onRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            'Register',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RegisterVehicleForm(onRegister: onRegister),
      ],
    );
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
          return Column(
            children: [
              const FormTextHeader(label: 'Brand'),
              FormTextEntry(
                label: 'Brand',
                controller: state.brandController,
              ),
              const FormTextHeader(label: 'Model'),
              FormTextEntry(
                label: 'Model',
                controller: state.modelController,
              ),
              const FormTextHeader(label: 'Manufacture Year'),
              FormTextEntry(
                label: 'Manufacture year',
                controller: state.manufactureYearController,
              ),
              const FormTextHeader(label: 'Model Year'),
              FormTextEntry(
                label: 'Model year',
                controller: state.manufactureYearController,
              ),
              const FormTextHeader(label: 'Plate'),
              FormTextEntry(
                label: 'Plate',
                controller: state.manufactureYearController,
              ),
              const FormTextHeader(label: 'Purchase date'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Purchase date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(state.purchaseDate != null
                        ? state.getDateString(state.purchaseDate!)
                        : 'Purchase date'),
                  ),
                  onTap: () async {
                    final now = DateTime.now();

                    final chosenDate = await showDatePicker(
                      context: context,
                      initialDate: state.purchaseDate ?? now,
                      firstDate: DateTime(1950),
                      lastDate: now,
                    );

                    if (chosenDate != null) {
                      state.setDate(chosenDate!);
                    } else {
                      print('No date selected');
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
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
