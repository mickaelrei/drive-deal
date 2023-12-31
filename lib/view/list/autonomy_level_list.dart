import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../entities/autonomy_level.dart';

/// Widget for listing [AutonomyLevel]s
class AutonomyLevelListPage extends StatelessWidget {
  /// Constructor
  const AutonomyLevelListPage({
    required this.items,
    this.navBar,
    this.onRegister,
    this.onAutonomyLevelEdit,
    super.key,
  });

  /// Page navigation bar
  final Widget? navBar;

  /// Calback for when an [AutonomyLevel] gets registered
  final void Function(AutonomyLevel)? onRegister;

  /// List of [AutonomyLevel]s
  final List<AutonomyLevel>? items;

  /// Callback for when an autonomy level is edited
  final void Function(AutonomyLevel)? onAutonomyLevelEdit;

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
          localization.noAutonomyLevels,
          style: const TextStyle(fontSize: 25),
        ),
      );
    } else {
      body = ListView.builder(
        itemCount: items!.length,
        itemBuilder: (context, index) {
          final autonomyLevel = items![index];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutonomyLevelTile(
              autonomyLevel: autonomyLevel,
              onEdit: onAutonomyLevelEdit,
            ),
          );
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(localization.autonomyLevel(2)),
        actions: [
          IconButton(
            onPressed: () async {
              // Wait until finished registering stores
              await Navigator.of(context).pushNamed(
                '/autonomy_level_register',
                arguments: {
                  'on_register': onRegister,
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

/// Widget for displaying a [AutonomyLevel] in a [ListView]
class AutonomyLevelTile extends StatelessWidget {
  /// Constructor
  const AutonomyLevelTile({
    required this.autonomyLevel,
    this.onEdit,
    super.key,
  });

  /// [AutonomyLevel] object to show
  final AutonomyLevel autonomyLevel;

  /// Optional callback for editing
  final void Function(AutonomyLevel)? onEdit;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Card(
      elevation: 5,
      shadowColor: Colors.grey,
      child: ListTile(
        title: Text(autonomyLevel.label),
        subtitle: Text(
          '${localization.storeProfit}: ${autonomyLevel.storePercent}%\n'
          '${localization.networkProfit}: ${autonomyLevel.networkPercent}%',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            await Navigator.of(context).pushNamed(
              '/autonomy_level_edit',
              arguments: {
                'on_edit': onEdit,
                'autonomy_level': autonomyLevel,
              },
            );
          },
        ),
      ),
    );
  }
}
