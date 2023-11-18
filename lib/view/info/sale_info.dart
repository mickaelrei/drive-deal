import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../entities/sale.dart';
import '../../repositories/sale_repository.dart';
import '../../usecases/sale_use_case.dart';
import '../../utils/formats.dart';
import '../../utils/forms.dart';

/// Provider for sale info page
class SaleInfoState with ChangeNotifier {
  /// Constructor
  SaleInfoState({
    Sale? sale,
    this.saleId,
  }) : assert(sale != null || saleId != null) {
    unawaited(init(sale));
  }

  bool _loaded = false;

  /// Whether the sale has loaded or not
  bool get loaded => _loaded;

  /// From which sale to show info
  late final Sale? sale;

  /// Sale ID in case no [Sale] is passed
  final int? saleId;

  /// To load sale
  final _saleUseCase = const SaleUseCase(SaleRepository());

  /// Method to initialize data
  Future<void> init(Sale? sale) async {
    // Initialize sale
    if (sale != null) {
      this.sale = sale;
    } else {
      // Get sale from given id
      this.sale = await _saleUseCase.selectById(saleId!);
    }

    // Set loaded
    _loaded = true;
    notifyListeners();
  }
}

/// Widget to show detailed info about a [Sale]
class SaleInfoPage extends StatelessWidget {
  /// Constructor
  const SaleInfoPage({
    this.sale,
    this.saleId,
    super.key,
  }) : assert(sale != null || saleId != null);

  /// Sale object
  final Sale? sale;

  /// Sale id
  final int? saleId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localization.saleInfo)),
      body: ChangeNotifierProvider<SaleInfoState>(
        create: (context) {
          return SaleInfoState(sale: sale, saleId: saleId);
        },
        child: Consumer<SaleInfoState>(
          builder: (_, state, __) {
            // Check if still loading
            if (!state.loaded) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Get sale
            final sale = state.sale;

            // Check if sale was found
            if (sale == null) {
              return const Center(
                child: Text(
                  'Sale not found!',
                  style: TextStyle(fontSize: 25),
                ),
              );
            }

            // Main widget
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextHeader(label: localization.vehicle(1)),
                ),
                InfoText(sale.vehicle.model),
                TextHeader(label: localization.customerName),
                InfoText(sale.customerName),
                TextHeader(label: localization.customerCpf),
                InfoText(sale.customerCpf),
                TextHeader(label: localization.saleDate),
                InfoText(formatDate(sale.saleDate)),
                TextHeader(label: localization.storeProfit),
                InfoText(formatPrice(sale.storeProfit)),
                TextHeader(label: localization.networkProfit),
                InfoText(formatPrice(sale.networkProfit)),
                TextHeader(label: localization.safetyProfit),
                InfoText(formatPrice(sale.safetyProfit)),
                TextHeader(label: localization.totalPrice),
                InfoText(formatPrice(sale.price)),
              ],
            );
          },
        ),
      ),
    );
  }
}
