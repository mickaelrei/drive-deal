import 'package:flutter/material.dart';

import '../../entities/partner_store.dart';

/// Widget for listing [PartnerStore]s
class PartnerStoreListPage extends StatelessWidget {
  /// Constructor
  const PartnerStoreListPage({required this.items, super.key});

  /// List of [PartnerStore]
  final Future<List<PartnerStore>> items;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PartnerStore>>(
      future: items,
      builder: (context, snapshot) {
        // Still waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        // No data
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No data found!'),
          );
        }

        // No items in list
        if (snapshot.data!.isEmpty) {
          const Center(
            child: Text('No partner stores found!'),
          );
        }

        // List of items
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            // Get partner store object
            final partnerStore = snapshot.data![index];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('Name: ${partnerStore.name}'),
                subtitle: Text(
                  'CNPJ: ${partnerStore.cnpj}\n'
                  'Autonomy Level: ${partnerStore.autonomyLevel.label}',
                ),
                isThreeLine: true,
                tileColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
