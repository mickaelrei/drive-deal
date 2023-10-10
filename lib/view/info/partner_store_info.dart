import 'package:flutter/material.dart';

import '../../entities/partner_store.dart';

/// Widget to show detailed info about a [PartnerStore]
class PartnerStoreInfoPage extends StatelessWidget {
  /// Constructor
  const PartnerStoreInfoPage({required this.partnerStore, super.key});

  /// PartnerStore object
  final PartnerStore partnerStore;

  @override
  Widget build(BuildContext context) {
    // TODO: Show name, CNPJ and user info
    return Center(
      child: Text('Store name: ${partnerStore.name}'),
    );
  }
}
