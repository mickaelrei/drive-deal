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
    if (partnerStore.sales.isEmpty) {
      return const Center(
        child: Text(
          'No sales!',
          style: TextStyle(fontSize: 25),
        ),
      );
    }

    return ListView.builder(
      itemCount: partnerStore.sales.length,
      itemBuilder: (context, index) {
        final sale = partnerStore.sales[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SaleTile(sale: sale),
        );
      },
    );
  }
}

/// Widget for displaying a [Sale] in a [ListView]
class SaleTile extends StatelessWidget {
  /// Constructor
  const SaleTile({required this.sale, super.key});

  /// [Sale] object to show
  final Sale sale;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey,
      child: ListTile(
        title: Text('Customer: ${sale.customerName} (${sale.customerCpf})'),
      ),
    );
  }
}

/// Widget for an image in a [SaleTile] with no images
class NoSaleTile extends StatelessWidget {
  /// Constructor
  const NoSaleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundColor: Colors.transparent,
      child: Icon(
        Icons.attach_money,
        color: Colors.grey,
      ),
    );
  }
}
