import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final localization = AppLocalizations.of(context)!;

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
  }
}
