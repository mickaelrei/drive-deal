import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    // Get scaffold body based on list being null, empty or not empty
    final Widget body;
    if (items == null) {
      body = Center(
        child: Text(localization.loading),
      );
    } else if (items!.isEmpty) {
      body = Center(
        child: Text(
          localization.noPartnerStores,
          style: const TextStyle(fontSize: 25),
        ),
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
              onEdit: () async {
                // Go in edit route
                await Navigator.of(context).pushNamed(
                  '/store_edit',
                  arguments: {
                    'user': user,
                    'partner_store': partnerStore,
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
        title: Text(localization.partnerStore(2)),
        actions: [
          IconButton(
            onPressed: () async {
              // Wait until finished registering stores
              await Navigator.of(context).pushNamed(
                '/store_register',
                arguments: {
                  'on_register': onPartnerStoreRegister,
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
    super.key,
  });

  /// [PartnerStore] object to show
  final PartnerStore partnerStore;

  /// Optional callback for edit button
  final void Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

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
        title: Text('${localization.name}: ${partnerStore.name}'),
        subtitle: Text(
          '${localization.cnpj}: ${partnerStore.cnpj}\n'
          '${localization.autonomyLevel(1)}: '
          '${partnerStore.autonomyLevel.label}',
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
