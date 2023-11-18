import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../entities/autonomy_level.dart';
import '../../repositories/autonomy_level_repository.dart';
import '../../usecases/autonomy_level_use_case.dart';
import '../../utils/dialogs.dart';
import '../../utils/forms.dart';
import '../../utils/safety_percent.dart';

/// Provider for edit autonomy level form
class AutonomyLevelEditState with ChangeNotifier {
  /// Constructor
  AutonomyLevelEditState({
    required this.autonomyLevel,
    this.onEdit,
  }) {
    init();
  }

  /// Which [AutonomyLevel] is being edited
  final AutonomyLevel autonomyLevel;

  final _formKey = GlobalKey<FormState>();

  /// Form key getter
  GlobalKey<FormState> get formKey => _formKey;

  /// Callback function to when a [AutonomyLevel] gets edited
  final void Function(AutonomyLevel)? onEdit;

  /// To update the autonomy level
  final _autonomyLevelUseCase = const AutonomyLevelUseCase(
    AutonomyLevelRepository(),
  );

  /// Controller for label field
  final TextEditingController labelController = TextEditingController();

  /// How much (int %) of sales go for store profit
  late double _storeProfitPercent;

  /// Store profit percent
  double get storeProfitPercent => _storeProfitPercent;

  /// How much (int %) of sales go for network profit
  late double _networkProfitPercent;

  /// Network profit percent
  double get networkProfitPercent => _networkProfitPercent;

  /// Method to init variables
  void init() {
    // Set percents
    _storeProfitPercent = autonomyLevel.storePercent;
    _networkProfitPercent = autonomyLevel.networkPercent;

    // Set label
    labelController.text = autonomyLevel.label;

    // Update
    notifyListeners();
  }

  /// When the slider for [storeProfitPercent] changes
  void onStoreProfitPercentChanged(double percent) {
    // Change store profit percent to new value
    _storeProfitPercent = min(percent, 100 - safetyPercent);

    // Calculate new network profit percent
    final newNetworkProfitPercent = 100 - safetyPercent - _storeProfitPercent;

    // Set network profit percent
    _networkProfitPercent = newNetworkProfitPercent;

    // Update screen
    notifyListeners();
  }

  /// When the slider for [networkProfitPercent] changes
  void onNetworkProfitPercentChanged(double percent) {
    // Change network profit percent to new value
    _networkProfitPercent = min(percent, 100 - safetyPercent);

    // Calculate new store profit percent
    final newStoreProfitPercent = 100 - safetyPercent - _networkProfitPercent;

    // Set store profit percent
    _storeProfitPercent = newStoreProfitPercent;

    // Update screen
    notifyListeners();
  }

  /// Method for edit attempt
  Future<String?> edit() async {
    // Update object
    autonomyLevel.label = labelController.text;
    autonomyLevel.storePercent = storeProfitPercent;
    autonomyLevel.networkPercent = networkProfitPercent;

    // Update in database
    await _autonomyLevelUseCase.update(autonomyLevel);

    // If no errors, call onEdit callback and return null meaning success
    if (onEdit != null) {
      onEdit!(autonomyLevel);
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    labelController.dispose();
  }
}

/// Form for editing a partner store
class AutonomyLevelEditForm extends StatelessWidget {
  /// Constructor
  const AutonomyLevelEditForm({
    required this.autonomyLevel,
    this.onEdit,
    super.key,
  });

  /// Which [AutonomyLevel] is being edited
  final AutonomyLevel autonomyLevel;

  /// Callback for when a [AutonomyLevel] gets edited
  final void Function(AutonomyLevel)? onEdit;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localization.editAutonomyLevel)),
      body: ChangeNotifierProvider<AutonomyLevelEditState>(
        create: (context) {
          return AutonomyLevelEditState(
            autonomyLevel: autonomyLevel,
            onEdit: onEdit,
          );
        },
        child: Consumer<AutonomyLevelEditState>(
          builder: (_, state, __) {
            return Form(
              key: state.formKey,
              child: ListView(
                children: [
                  FormTitle(title: localization.edit),
                  TextHeader(label: localization.label),
                  FormTextEntry(
                    label: localization.label,
                    controller: state.labelController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return localization.labelNotEmpty;
                      }
                      if (text.length < 3) {
                        return localization.labelMinSize(3);
                      }
                      return null;
                    },
                  ),
                  TextHeader(label: localization.saleStoreProfitRegister),
                  Slider(
                    max: 100.0,
                    value: state.storeProfitPercent,
                    onChanged: state.onStoreProfitPercentChanged,
                    label: '${state.storeProfitPercent.toStringAsFixed(0)}%',
                    divisions: 100,
                  ),
                  TextHeader(label: localization.saleNetworkProfitRegister),
                  Slider(
                    max: 100.0,
                    value: state.networkProfitPercent,
                    onChanged: state.onNetworkProfitPercentChanged,
                    label: '${state.networkProfitPercent.toStringAsFixed(0)}%',
                    divisions: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SubmitButton(
                      label: localization.edit,
                      onPressed: () async {
                        // Validate inputs
                        if (!state.formKey.currentState!.validate()) return;

                        // Try editing
                        final result = await state.edit();

                        // Show dialog with edit result
                        if (context.mounted) {
                          await editDialog(context, result);
                        }

                        // Go back to autonomy level listing
                        if (result == null && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
