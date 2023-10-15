import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../entities/partner_store.dart';
import '../../utils/formats.dart';
import '../../utils/forms.dart';

/// Widget to show detailed info about a [PartnerStore]
class PartnerStoreInfoPage extends StatelessWidget {
  /// Constructor
  const PartnerStoreInfoPage({required this.partnerStore, super.key});

  /// PartnerStore object
  final PartnerStore partnerStore;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    // Calculate total profits
    var totalNetworkProfit = 0.0;
    var totalStoreProfit = 0.0;
    var totalSafetyProfit = 0.0;
    for (final sale in partnerStore.sales) {
      totalNetworkProfit += sale.networkProfit;
      totalStoreProfit += sale.storeProfit;
      totalSafetyProfit += sale.safetyProfit;
    }

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
        InfoText(formatPrice(totalNetworkProfit)),
        TextHeader(label: localization.totalStoreProfit),
        InfoText(formatPrice(totalStoreProfit)),
        TextHeader(label: localization.totalSafetyProfit),
        InfoText(formatPrice(totalSafetyProfit)),
      ],
    );
  }
}
