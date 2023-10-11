import 'package:flutter/material.dart';

import '../../entities/partner_store.dart';
import '../../utils/forms.dart';

/// Widget to show detailed info about a [PartnerStore]
class PartnerStoreInfoPage extends StatelessWidget {
  /// Constructor
  const PartnerStoreInfoPage({required this.partnerStore, super.key});

  /// PartnerStore object
  final PartnerStore partnerStore;

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}
