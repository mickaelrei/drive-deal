import 'package:flutter/material.dart';

import '../../entities/partner_store.dart';
import '../../entities/sale.dart';

/// Widget for listing [Sale]s
class SaleListPage extends StatelessWidget {
  /// Constructor
  const SaleListPage({required this.partnerStore, super.key});

  /// [Sale] objects will be listed from this [PartnerStore] object
  final PartnerStore partnerStore;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
