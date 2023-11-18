import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../entities/sale.dart';
import '../../utils/formats.dart';
import '../main_state.dart';

/// Provider for sale listing page
class SaleListState with ChangeNotifier {
  /// Constructor
  SaleListState({required this.partnerStore}) {
    // Filter list once
    sliderChanged(sliderRange);
  }

  /// From which partner store are the sales from
  final PartnerStore partnerStore;

  /// Min-max values for sale date range
  RangeValues sliderRange = const RangeValues(0.0, 1.0);

  /// List of sales inside the specified min-max range
  final inRangeSales = <Sale>[];

  /// Method to change slider
  void sliderChanged(RangeValues values) {
    // Set range values
    sliderRange = values;

    // Get time range
    final timeRange = getSaleTimeRange();

    // Get min-max sale times
    final minSaleTime = lerpDouble(
      timeRange.start,
      timeRange.end,
      sliderRange.start,
    )!;
    final maxSaleTime = lerpDouble(
      timeRange.start,
      timeRange.end,
      sliderRange.end,
    )!;

    // Filter list of in-range sales
    final filteredSales = partnerStore.sales.where((sale) {
      final saleTime = sale.saleDate.millisecondsSinceEpoch;

      return saleTime >= minSaleTime && saleTime <= maxSaleTime;
    });

    // Update list
    inRangeSales
      ..clear()
      ..addAll(filteredSales);

    // Update screen
    notifyListeners();
  }

  /// Method to get a time range based on oldest and newest sale
  RangeValues getSaleTimeRange() {
    // Get oldest and newest sale times
    final oldestSaleTime = partnerStore.sales.fold(
      DateTime.now().millisecondsSinceEpoch,
      (previousValue, sale) {
        final saleTime = sale.saleDate.millisecondsSinceEpoch;
        return min(saleTime, previousValue);
      },
    );
    final newestSaleTime = partnerStore.sales.fold(
      oldestSaleTime,
      (previousValue, sale) {
        final saleTime = sale.saleDate.millisecondsSinceEpoch;
        return max(saleTime, previousValue);
      },
    );

    // Create range values (with a little offset to prevent same-time errors)
    return RangeValues(oldestSaleTime - 100, newestSaleTime + 100);
  }

  /// Method to get the slider semantics
  RangeLabels getSliderLabels() {
    final timeRange = getSaleTimeRange();

    // Calculate time for start and end of current slider range
    final timeStart = lerpDouble(
      timeRange.start,
      timeRange.end,
      sliderRange.start,
    )!;
    final timeEnd = lerpDouble(
      timeRange.start,
      timeRange.end,
      sliderRange.end,
    )!;

    // Return formatted date of drag time
    final startLabel = formatDate(
      DateTime.fromMillisecondsSinceEpoch(timeStart.floor()),
    );
    final endLabel = formatDate(
      DateTime.fromMillisecondsSinceEpoch(timeEnd.floor()),
    );
    return RangeLabels(startLabel, endLabel);
  }
}

/// Widget for listing [Sale]s
class SaleListPage extends StatelessWidget {
  /// Constructor
  const SaleListPage({
    required this.partnerStore,
    this.navBar,
    this.onSaleRegister,
    super.key,
  });

  /// [Sale] objects will be listed from this [PartnerStore] object
  final PartnerStore partnerStore;

  /// Page navigation bar
  final Widget? navBar;

  /// Optional callback for when a sale gets registered
  final void Function(Sale)? onSaleRegister;

  @override
  Widget build(BuildContext context) {
    final mainState = Provider.of<MainState>(context, listen: false);
    final localization = AppLocalizations.of(context)!;

    // Scaffold body
    late final Widget body;

    // Check if list of sales is empty
    if (partnerStore.sales.isEmpty) {
      body = Center(
        child: Text(
          localization.noSales,
          style: const TextStyle(fontSize: 25),
        ),
      );
    } else {
      body = ChangeNotifierProvider(
        create: (context) {
          return SaleListState(partnerStore: partnerStore);
        },
        child: Consumer<SaleListState>(
          builder: (_, state, __) {
            return Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        localization.dateInterval,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Expanded(
                      child: RangeSlider(
                        values: state.sliderRange,
                        divisions: 25,
                        onChanged: state.sliderChanged,
                        labels: state.getSliderLabels(),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.inRangeSales.length,
                    itemBuilder: (context, index) {
                      final sale = state.inRangeSales[index];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SaleTile(
                          sale: sale,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(localization.sale(2)),
        actions: [
          IconButton(
            onPressed: () async {
              await context.push(
                '/sale/register',
                extra: {
                  'user_id': mainState.loggedUser?.id,
                  'partner_store': partnerStore,
                  'on_register': onSaleRegister,
                },
              );
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      bottomNavigationBar: navBar,
      body: body,
    );
  }
}

/// Widget for displaying a [Sale] in a [ListView]
class SaleTile extends StatelessWidget {
  /// Constructor
  const SaleTile({
    required this.sale,
    super.key,
  });

  /// [Sale] object to show
  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final mainState = Provider.of<MainState>(context, listen: false);
    final localization = AppLocalizations.of(context)!;

    return Card(
      elevation: 5,
      shadowColor: Colors.grey,
      child: ListTile(
        onTap: () async {
          await context.push(
            '/sale/info/${sale.id}',
            extra: {
              'user_id': mainState.loggedUser?.id,
              'sale': sale,
            },
          );
        },
        title: Text(
          '${localization.customer}: '
          '${sale.customerName} (${sale.customerCpf})',
        ),
        subtitle: Text('${localization.soldOn} ${formatDate(sale.saleDate)}'),
      ),
    );
  }
}
