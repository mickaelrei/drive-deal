import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../repositories/partner_store_repository.dart';
import '../../usecases/partner_store_use_case.dart';
import '../../utils/formats.dart';
import '../../utils/forms.dart';

/// Provider for partner store info page
class PartnerStoreInfoState with ChangeNotifier {
  /// Constructor
  PartnerStoreInfoState({
    PartnerStore? partnerStore,
    this.partnerStoreId,
  }) : assert(partnerStore != null || partnerStoreId != null) {
    unawaited(init(partnerStore));
  }

  bool _loaded = false;

  /// Whether the partnerStore has loaded or not
  bool get loaded => _loaded;

  /// From which partnerStore to show info
  late final PartnerStore? partnerStore;

  /// PartnerStore ID in case no [PartnerStore] is passed
  final int? partnerStoreId;

  /// To load partnerStore
  final _partnerStoreUseCase =
      PartnerStoreUseCase(const PartnerStoreRepository());

  /// Total network profit of the related partner store
  double get totalNetworkProfit {
    if (partnerStore == null) return 0.0;

    // Return total network profit
    return partnerStore!.sales.fold(
      0.0,
      (previousValue, element) => previousValue + element.networkProfit,
    );
  }

  /// Total store profit of the related partner store
  double get totalStoreProfit {
    if (partnerStore == null) return 0.0;

    // Return total network profit
    return partnerStore!.sales.fold(
      0.0,
      (previousValue, element) => previousValue + element.networkProfit,
    );
  }

  /// Total safety profit of the related partner store
  double get totalSafetyProfit {
    if (partnerStore == null) return 0.0;

    // Return total network profit
    return partnerStore!.sales.fold(
      0.0,
      (previousValue, element) => previousValue + element.networkProfit,
    );
  }

  /// Initialize data
  Future<void> init(PartnerStore? partnerStore) async {
    // Initialize partnerStore
    if (partnerStore != null) {
      this.partnerStore = partnerStore;
    } else {
      // Get partnerStore from given id
      this.partnerStore =
          await _partnerStoreUseCase.selectById(partnerStoreId!);
    }

    // Set loaded
    _loaded = true;
    notifyListeners();
  }
}

/// Widget to show detailed info about a [PartnerStore]
class PartnerStoreInfoPage extends StatelessWidget {
  /// Constructor
  const PartnerStoreInfoPage({
    this.partnerStore,
    this.partnerStoreId,
    super.key,
  }) : assert(partnerStore != null || partnerStoreId != null);

  /// PartnerStore object
  final PartnerStore? partnerStore;

  /// Store id in case no object is passed
  final int? partnerStoreId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(localization.partnerStoreInfo)),
      body: ChangeNotifierProvider<PartnerStoreInfoState>(
        create: (context) {
          return PartnerStoreInfoState(
            partnerStore: partnerStore,
            partnerStoreId: partnerStoreId,
          );
        },
        child: Consumer<PartnerStoreInfoState>(
          builder: (_, state, __) {
            // Check if still loading
            if (!state.loaded) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Get partner store
            final partnerStore = state.partnerStore;

            // Check if partner store was found
            if (partnerStore == null) {
              return const Center(
                child: Text(
                  'Partner Store not found!',
                  style: TextStyle(fontSize: 25),
                ),
              );
            }

            // Main widget
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextHeader(label: localization.storeName),
                ),
                InfoText(partnerStore.name),
                TextHeader(label: localization.cnpj),
                InfoText(partnerStore.cnpj),
                TextHeader(label: localization.autonomyLevel(1)),
                InfoText(partnerStore.autonomyLevel.label),
                TextHeader(label: localization.registeredVehicles),
                InfoText(partnerStore.vehicles.length.toString()),
                TextHeader(label: localization.registeredSales),
                InfoText(partnerStore.sales.length.toString()),
                TextHeader(label: localization.totalNetworkProfit),
                InfoText(formatPrice(state.totalNetworkProfit)),
                TextHeader(label: localization.totalStoreProfit),
                InfoText(formatPrice(state.totalStoreProfit)),
                TextHeader(label: localization.totalSafetyProfit),
                InfoText(formatPrice(state.totalSafetyProfit)),
              ],
            );
          },
        ),
      ),
    );
  }
}
