import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../entities/sale.dart';
import '../../entities/vehicle.dart';
import '../../repositories/sale_repository.dart';
import '../../usecases/sale_use_case.dart';
import '../form_utils.dart';

/// Provider for register sale page
class RegisterSaleState with ChangeNotifier {
  /// Constructor
  RegisterSaleState({required this.partnerStore, this.onRegister}) {
    init();
  }

  /// What [PartnerStore] is this provider linked to
  final PartnerStore partnerStore;

  /// Callback function for when a sale gets registered
  final void Function(Sale)? onRegister;

  /// Operations on [Sale] database table
  final SaleUseCase _saleUseCase = const SaleUseCase(
    SaleRepository(),
  );

  /// Controller for [Sale.customerCpf]
  final TextEditingController customerCpfController = TextEditingController();

  /// Controller for [Sale.customerName]
  final TextEditingController customerNameController = TextEditingController();

  /// Controller for [Sale.price]
  final TextEditingController priceController = TextEditingController();

  /// What [Vehicle] is this [Sale] linked to
  Vehicle? _saleVehicle;

  /// Input sale date
  DateTime? saleDate;

  /// Method to set sale date
  void setDate(DateTime date) {
    saleDate = date;

    // Update to show new picked date
    notifyListeners();
  }

  /// Method to set the [Vehicle] this [Sale] is linked to
  void setVehicle(Vehicle? vehicle) {
    _saleVehicle = vehicle!;
  }

  /// Initialize some lists
  void init() {}

  /// Method to clear everything for a new register
  void clear() {
    // Reset controllers

    notifyListeners();
  }

  /// Method to try registering a sale
  Future<String?> register() async {
    // Check if all inputs are set
    if (_saleVehicle == null) {
      return 'Choose a vehicle';
    }

    // Get total price
    final price = double.tryParse(priceController.text);
    if (price == null) {
      return 'Price is in invalid format';
    }

    // Calculate store, network and safety profit
    final storeProfit = _saleUseCase.calculateStoreProfit(
      totalPrice: price,
      autonomyLevel: partnerStore.autonomyLevel,
    );
    final networkProfit = _saleUseCase.calculateNetworkProfit(
      totalPrice: price,
      autonomyLevel: partnerStore.autonomyLevel,
    );
    final safetyProfit = _saleUseCase.calculateSafetyProfit(
      totalPrice: price,
      autonomyLevel: partnerStore.autonomyLevel,
    );

    // Create sale object and insert into database
    print(_saleVehicle);
    final sale = Sale(
      storeId: partnerStore.id!,
      customerCpf: customerCpfController.text,
      customerName: customerNameController.text,
      vehicle: _saleVehicle!,
      saleDate: saleDate!,
      storeProfit: storeProfit,
      networkProfit: networkProfit,
      safetyProfit: safetyProfit,
    );
    final saleId = await _saleUseCase.insert(sale);

    // Set id
    sale.id = saleId;
    if (onRegister != null) {
      onRegister!(sale);
    }

    // Success
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    customerCpfController.dispose();
    customerNameController.dispose();
    priceController.dispose();
  }
}

/// Form for [Sale] registering
class RegisterSaleForm extends StatelessWidget {
  /// Constructor
  const RegisterSaleForm(
      {required this.partnerStore, this.onRegister, super.key});

  /// Which [PartnerStore] will the registered sale be linked to
  final PartnerStore partnerStore;

  /// Callback function for when a sale gets registered
  final void Function(Sale)? onRegister;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterSaleState>(
      create: (context) {
        return RegisterSaleState(
          partnerStore: partnerStore,
          onRegister: onRegister,
        );
      },
      child: Consumer<RegisterSaleState>(
        builder: (_, state, __) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FormTitle(
                  title: 'Register Sale',
                ),
                const FormTextHeader(label: 'Vehicle'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<Vehicle>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: partnerStore.vehicles
                        .map(
                          (e) => DropdownMenuItem<Vehicle>(
                            value: e,
                            child: Text(e.model),
                          ),
                        )
                        .toList(),
                    onChanged: state.setVehicle,
                  ),
                ),
                const FormTextHeader(label: 'Customer name'),
                FormTextEntry(
                  label: 'Customer Name',
                  controller: state.customerNameController,
                ),
                const FormTextHeader(label: 'Customer CPF'),
                FormTextEntry(
                  label: 'Customer CPF',
                  controller: state.customerCpfController,
                ),
                const FormTextHeader(label: 'Sale price'),
                FormTextEntry(
                  validator: (text) {
                    final price = double.tryParse(text!);
                    if (price == null) {
                      return 'Price needs to be a number';
                    }
                    return null;
                  },
                  label: 'Price',
                  controller: state.priceController,
                ),
                const FormTextHeader(label: 'Sale date'),
                DatePicker(
                  initialDate: state.saleDate,
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
