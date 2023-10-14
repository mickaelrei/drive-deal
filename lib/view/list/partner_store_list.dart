import 'dart:async';

import 'package:flutter/material.dart';

import '../../entities/partner_store.dart';
import '../../entities/user.dart';

/// Widget for listing [PartnerStore]s
class PartnerStoreListPage extends StatelessWidget {
  /// Constructor
  const PartnerStoreListPage({
    required this.items,
    this.navBar,
    this.onPartnerStoreRegister,
    this.theme = UserSettings.defaultAppTheme,
    super.key,
  });

  /// Page navigation bar
  final Widget? navBar;

  /// Callback for partner store registering
  final void Function(PartnerStore)? onPartnerStoreRegister;

  /// List of [PartnerStore]s
  final Future<List<PartnerStore>> items;

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
              child: Text(
                'No data found!',
                style: TextStyle(fontSize: 17),
              ),
            );
          }

          // No items in list
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No partner stores registered'),
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
                child: PartnerStoreTile(
                  partnerStore: partnerStore,
                  theme: theme,
                ),
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
  const PartnerStoreTile({
    required this.partnerStore,
    this.theme = UserSettings.defaultAppTheme,
    super.key,
  });

  /// [PartnerStore] object to show
  final PartnerStore partnerStore;

  /// Theme
  final AppTheme theme;

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
              'theme': theme,
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
