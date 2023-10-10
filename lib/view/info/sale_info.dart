import 'package:flutter/material.dart';

import '../../entities/sale.dart';

/// Widget to show detailed info about a [Sale]
class SaleInfoPage extends StatelessWidget {
  /// Constructor
  const SaleInfoPage({required this.sale, super.key});

  /// Sale object
  final Sale sale;

  @override
  Widget build(BuildContext context) {
    // TODO: Show customer info, sale profit for store, network and safety
    return Center(
      child: Text('Sale customer: ${sale.customerName}'),
    );
  }
}
