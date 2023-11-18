import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  /// ructor
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

  /// Vehicle date to restrain sale date
  DateTime? vehiclePurchaseDate;

  /// Method to set sale date
  void setDate(DateTime date) {
    saleDate = date;

    // Update to show new picked date
    notifyListeners();
  }

  /// Method to set the [Vehicle] this [Sale] is linked to
  void setVehicle(Vehicle? vehicle) {
    // Set vehicle
    _saleVehicle = vehicle!;

    // Set first date and reset current input date
    vehiclePurchaseDate = _saleVehicle!.purchaseDate;
    saleDate = null;
    notifyListeners();
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
  Future<String?> register(BuildContext context) async {
    final localization = AppLocalizations.of(context)!;

    // Check if all inputs are set
    if (_saleVehicle == null) {
      return localization.chooseVehicle;
    }

    // Check if sale date is set
    if (saleDate == null) {
      // return localization.chooseSaleDate;
      return 'Choose a sale date';
    }

    // Make sure that sale date is newer than vehicle purchase date
    if (saleDate!.compareTo(_saleVehicle!.purchaseDate) < 0) {
      return localization.saleBeforePurchase;
    }

    // Get total price
    final price = double.tryParse(priceController.text);
    if (price == null) {
      return localization.invalidPrice;
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
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localization.registerSale)),
      body: ChangeNotifierProvider<SaleRegisterState>(
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
                    FormTitle(title: localization.register),
                    TextHeader(label: localization.vehicle(1)),
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
                    TextHeader(label: localization.customerName),
                    FormTextEntry(
                      label: localization.customerName,
                      controller: state.customerNameController,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return localization.labelNotEmpty;
                        }
                        if (text.length < 3) {
                          return localization.labelMinSize(3);
                        }
                        return null;
                      },
                    ),
                    TextHeader(label: localization.customerCpf),
                    FormTextEntry(
                      label: localization.customerCpf,
                      controller: state.customerCpfController,
                    ),
                    TextHeader(label: localization.salePrice),
                    FormTextEntry(
                      validator: (text) {
                        final price = double.tryParse(text!);
                        if (price == null) {
                          return localization.invalidPrice;
                        }
                        return null;
                      },
                      label: localization.salePrice,
                      controller: state.priceController,
                    ),
                    TextHeader(label: localization.saleDate),
                    DatePicker(
                      hintText: localization.saleDate,
                      firstDate: state.vehiclePurchaseDate,
                      initialDate: state.saleDate,
                      onDatePicked: state.setDate,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SubmitButton(
                        label: localization.register,
                        onPressed: () async {
                          // Validate inputs
                          if (!state.formKey.currentState!.validate()) return;

                          // Try registering
                          final result = await state.register(context);

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
      ),
    );
  }
}
