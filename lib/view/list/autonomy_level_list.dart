import 'dart:async';

import 'package:flutter/material.dart';

import '../../entities/autonomy_level.dart';
import '../../entities/user.dart';

/// Widget for listing [AutonomyLevel]s
class AutonomyLevelListPage extends StatelessWidget {
  /// Constructor
  const AutonomyLevelListPage({
    required this.items,
    this.navBar,
    this.onRegister,
    this.theme = UserSettings.defaultAppTheme,
    this.onAutonomyLevelEdit,
    super.key,
  });

  /// Page navigation bar
  final Widget? navBar;

  /// Calback for when an [AutonomyLevel] gets registered
  final void Function(AutonomyLevel)? onRegister;

  /// List of [AutonomyLevel]s
  final Future<List<AutonomyLevel>> items;

  /// Callback for when an autonomy level is edited
  final void Function(AutonomyLevel)? onAutonomyLevelEdit;

  /// Theme
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Autonomy Levels')),
      bottomNavigationBar: navBar,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Wait until finished registering stores
          await Navigator.of(context).pushNamed(
            '/autonomy_level_register',
            arguments: {
              'on_register': onRegister,
              'theme': theme,
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.data == null) {
            return const Center(
              child: Text(
                'No data',
                style: TextStyle(fontSize: 17),
              ),
            );
          }

          // No items in list
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No autonomy levels registered'),
            );
          }

          final autonomyLevels = snapshot.data!;
          return ListView.builder(
            itemCount: autonomyLevels.length,
            itemBuilder: (context, index) {
              final autonomyLevel = autonomyLevels[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutonomyLevelTile(
                  autonomyLevel: autonomyLevel,
                  theme: theme,
                  onEdit: onAutonomyLevelEdit,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget for displaying a [AutonomyLevel] in a [ListView]
class AutonomyLevelTile extends StatelessWidget {
  /// Constructor
  const AutonomyLevelTile({
    required this.autonomyLevel,
    this.theme = UserSettings.defaultAppTheme,
    this.onEdit,
    super.key,
  });

  /// [AutonomyLevel] object to show
  final AutonomyLevel autonomyLevel;

  /// Optional callback for editing
  final void Function(AutonomyLevel)? onEdit;

  /// Theme
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey,
      child: ListTile(
        title: Text(autonomyLevel.label),
        subtitle: Text(
          'Sale store profit: ${autonomyLevel.storePercent}%\n'
          'Sale network profit: ${autonomyLevel.networkPercent}%',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            await Navigator.of(context).pushNamed(
              '/autonomy_level_edit',
              arguments: {
                'theme': theme,
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
