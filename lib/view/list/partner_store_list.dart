import 'package:flutter/material.dart';

import '../../entities/partner_store.dart';
import '../../entities/user.dart';

/// Widget for listing [PartnerStore]s
class PartnerStoreListPage extends StatelessWidget {
  /// Constructor
  const PartnerStoreListPage({
    required this.user,
    this.navBar,
    this.onPartnerStoreRegister,
    required this.items,
    this.onStoreEdit,
    this.theme = UserSettings.defaultAppTheme,
    super.key,
  });

  /// User for authentication
  final User user;

  /// Page navigation bar
  final Widget? navBar;

  /// Callback for partner store registering
  final void Function(PartnerStore)? onPartnerStoreRegister;

  /// List of [PartnerStore]s
  final List<PartnerStore>? items;

  /// Optional callback for store edit
  final void Function(PartnerStore)? onStoreEdit;

  /// Theme
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    // Get scaffold body based on list being null, empty or not empty
    final Widget body;
    if (items == null) {
      body = const Center(
        child: Text('Loading...'),
      );
    } else if (items!.isEmpty) {
      body = const Center(
        child: Text('No partner stores registered!'),
      );
    } else {
      body = ListView.builder(
        itemCount: items!.length,
        itemBuilder: (context, index) {
          // Get partner store object
          final partnerStore = items![index];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: PartnerStoreTile(
              partnerStore: partnerStore,
              theme: theme,
              onEdit: () async {
                // Go in edit route
                await Navigator.of(context).pushNamed(
                  '/store_edit',
                  arguments: {
                    'user': user,
                    'partner_store': partnerStore,
                    'theme': theme,
                  },
                );

                // Call edit callback
                if (onStoreEdit != null) {
                  onStoreEdit!(partnerStore);
                }
              },
            ),
          );
        },
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Partner Stores'),
        actions: [
          IconButton(
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
            icon: const Icon(Icons.add),
          )
        ],
      ),
      bottomNavigationBar: navBar,
      body: body,
    );
  }
}

/// Widget for displaying a [PartnerStore] in a [ListView]
class PartnerStoreTile extends StatelessWidget {
  /// Constructor
  const PartnerStoreTile({
    required this.partnerStore,
    this.onEdit,
    this.theme = UserSettings.defaultAppTheme,
    super.key,
  });

  /// [PartnerStore] object to show
  final PartnerStore partnerStore;

  /// Optional callback for edit button
  final void Function()? onEdit;

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
        trailing: IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit),
        ),
      ),
    );
  }
}
