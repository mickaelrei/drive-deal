import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../entities/sale.dart';
import '../../entities/vehicle.dart';

import '../../repositories/sale_repository.dart';
import '../../usecases/sale_use_case.dart';

import '../../utils/dialogs.dart';
import '../../utils/forms.dart';

/// Provider for sale register page
class SaleRegisterState with ChangeNotifier {
  /// Constructor
  SaleRegisterState({required this.partnerStore, this.onRegister}) {
    init();
  }

  /// What [PartnerStore] is this provider linked to
  final PartnerStore partnerStore;

  final _formKey = GlobalKey<FormState>();

  /// Form key getter
  GlobalKey<FormState> get formKey => _formKey;

  /// List of vehicles available for sale
  final availableVehicles = <Vehicle>[];

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
  void init() {
    availableVehicles.clear();

    // Filter for not sold vehicles
    final notSold = partnerStore.vehicles.where((vehicle) => !vehicle.sold);

    // Add to list
    availableVehicles.addAll(notSold);
  }

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

    // Check if sale date is set
    if (saleDate == null) {
      return 'Sale date is required';
    }

    // Make sure that sale date is newer than vehicle purchase date
    if (saleDate!.compareTo(_saleVehicle!.purchaseDate) < 0) {
      return 'Sale date needs to be after vehicle purchase date';
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
    await _saleUseCase.insert(sale);

    // Call onRegister callback
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
class SaleRegisterForm extends StatelessWidget {
  /// Constructor
  const SaleRegisterForm({
    required this.partnerStore,
    this.onRegister,
    super.key,
  });

  /// Which [PartnerStore] will the registered sale be linked to
  final PartnerStore partnerStore;

  /// Callback function for when a sale gets registered
  final void Function(Sale)? onRegister;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SaleRegisterState>(
      create: (context) {
        return SaleRegisterState(
          partnerStore: partnerStore,
          onRegister: onRegister,
        );
      },
      child: Consumer<SaleRegisterState>(
        builder: (_, state, __) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Form(
              key: state.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FormTitle(
                    title: 'Register Sale',
                  ),
                  const TextHeader(label: 'Vehicle'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<Vehicle>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      items: state.availableVehicles
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
                  const TextHeader(label: 'Customer name'),
                  FormTextEntry(
                    label: 'Customer Name',
                    controller: state.customerNameController,
                  ),
                  const TextHeader(label: 'Customer CPF'),
                  FormTextEntry(
                    label: 'Customer CPF',
                    controller: state.customerCpfController,
                  ),
                  const TextHeader(label: 'Sale price'),
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
                  const TextHeader(label: 'Sale date'),
                  DatePicker(
                    initialDate: state.saleDate,
                    onDatePicked: state.setDate,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SubmitButton(
                      label: 'Register',
                      onPressed: () async {
                        // Validate inputs
                        if (!state.formKey.currentState!.validate()) return;

                        // Try registering
                        final result = await state.register();

                        // Show dialog with register result
                        if (context.mounted) {
                          await registerDialog(context, result);
                        }

                        // Go back to sale listing
                        if (result == null) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
