import 'package:flutter/material.dart';

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
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: TextHeader(label: 'Store name'),
        ),
        InfoText(partnerStore.name),
        const TextHeader(label: 'CNPJ'),
        InfoText(partnerStore.cnpj),
        const TextHeader(label: 'Autonomy Level'),
        InfoText(partnerStore.autonomyLevel.label),
        const TextHeader(label: 'Registered vehicles'),
        InfoText(partnerStore.vehicles.length.toString()),
        const TextHeader(label: 'Registered sales'),
        InfoText(partnerStore.sales.length.toString()),
        const TextHeader(label: 'Total network profit'),
        InfoText(formatPrice(totalNetworkProfit)),
        const TextHeader(label: 'Total store profit'),
        InfoText(formatPrice(totalStoreProfit)),
        const TextHeader(label: 'Total safety profit'),
        InfoText(formatPrice(totalSafetyProfit)),
      ],
    );
  }
}
