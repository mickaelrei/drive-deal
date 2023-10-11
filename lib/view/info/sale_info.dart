import 'package:flutter/material.dart';

import '../../entities/sale.dart';
import '../../utils/formats.dart';
import '../../utils/forms.dart';

/// Widget to show detailed info about a [Sale]
class SaleInfoPage extends StatelessWidget {
  /// Constructor
  const SaleInfoPage({required this.sale, super.key});

  /// Sale object
  final Sale sale;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: TextHeader(label: 'Customer name'),
        ),
        InfoText(sale.customerName),
        const TextHeader(label: 'Customer CPF'),
        InfoText(sale.customerCpf),
        const TextHeader(label: 'Sale date'),
        InfoText(formatDate(sale.saleDate)),
        const TextHeader(label: 'Store profit'),
        InfoText(formatPrice(sale.storeProfit)),
        const TextHeader(label: 'Network profit'),
        InfoText(formatPrice(sale.networkProfit)),
        const TextHeader(label: 'Safety profit'),
        InfoText(formatPrice(sale.safetyProfit)),
        const TextHeader(label: 'Total price'),
        InfoText(formatPrice(sale.price)),
      ],
    );
  }
}
