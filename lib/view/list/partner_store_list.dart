import 'package:flutter/material.dart';

import '../../entities/partner_store.dart';
import '../../entities/user.dart';

/// Widget for listing [PartnerStore]s
class PartnerStoreListPage extends StatelessWidget {
  /// Constructor
  const PartnerStoreListPage({
    required this.items,
    required this.user,
    this.navBar,
    this.onPartnerStoreRegister,
    this.theme = UserSettings.defaultAppTheme,
    super.key,
  });

  /// Page navigation bar
  final Widget? navBar;

  /// List of [PartnerStore]
  final Future<List<PartnerStore>> items;

  /// Admin user
  final User user;

  /// Callback for partner store registering
  final void Function(PartnerStore)? onPartnerStoreRegister;

  /// Theme
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Wait until finished registering stores
          await Navigator.of(context).pushNamed(
            '/store_register',
            arguments: {
              'user': user,
              'on_register': onPartnerStoreRegister,
              'theme': theme,
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: navBar,
      appBar: AppBar(
        title: const Text('Partner Stores'),
      ),
      body: FutureBuilder<List<PartnerStore>>(
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
                child: PartnerStoreTile(partnerStore: partnerStore),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget for displaying a [PartnerStore] in a [ListView]
class PartnerStoreTile extends StatelessWidget {
  /// Constructor
  const PartnerStoreTile({required this.partnerStore, super.key});

  /// [PartnerStore] object to show
  final PartnerStore partnerStore;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey,
      child: ListTile(
        onTap: () async {
          await Navigator.of(context).pushNamed(
            '/store_info',
            arguments: {
              'partner_store': partnerStore,
            },
          );
        },
        title: Text('Name: ${partnerStore.name}'),
        subtitle: Text(
          'CNPJ: ${partnerStore.cnpj}\n'
          'Autonomy Level: ${partnerStore.autonomyLevel.label}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
