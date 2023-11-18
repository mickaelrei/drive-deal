import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../entities/autonomy_level.dart';
import '../../repositories/autonomy_level_repository.dart';
import '../../usecases/autonomy_level_use_case.dart';
import '../../utils/dialogs.dart';
import '../../utils/forms.dart';
import '../../utils/safety_percent.dart';

/// Provider for register autonomy level form
class AutonomyLevelRegisterState with ChangeNotifier {
  /// Constructor
  AutonomyLevelRegisterState({this.onRegister}) {
    init();
  }

  final _formKey = GlobalKey<FormState>();

  /// Form key getter
  GlobalKey<FormState> get formKey => _formKey;

  /// Callback function to when a [AutonomyLevel] gets registered
  final void Function(AutonomyLevel)? onRegister;

  /// To insert a new [AutonomyLevel] in database
  final _autonomyLevelUseCase = const AutonomyLevelUseCase(
    AutonomyLevelRepository(),
  );

  /// Controller for label field
  final TextEditingController labelController = TextEditingController();

  /// How much (int %) of sales go for store profit
  double _storeProfitPercent = 75;

  /// Store profit percent
  double get storeProfitPercent => _storeProfitPercent;

  /// How much (int %) of sales go for network profit
  double _networkProfitPercent = 24;

  /// Network profit percent
  double get networkProfitPercent => _networkProfitPercent;

  /// Method to init variables
  void init() {
    // Adjust store profit based on safety percent
    _storeProfitPercent = clampDouble(
      _storeProfitPercent,
      0,
      100 - safetyPercent,
    );

    // Adjust network profit based on store profit
    _networkProfitPercent = 100 - _storeProfitPercent - safetyPercent;
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

  /// Method for register attempt
  Future<String?> register() async {
    // Create a new autonomy level and add it to the database
    final autonomyLevel = AutonomyLevel(
      label: labelController.text,
      storePercent: _storeProfitPercent,
      networkPercent: _networkProfitPercent,
    );
    await _autonomyLevelUseCase.insert(autonomyLevel);

    // If no errors, call onRegister callback and return null meaning success
    if (onRegister != null) {
      onRegister!(autonomyLevel);
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    labelController.dispose();
  }
}

/// Form for registering a partner store
class AutonomyLevelRegisterForm extends StatelessWidget {
  /// Constructor
  const AutonomyLevelRegisterForm({
    this.onRegister,
    super.key,
  });

  /// Callback for when a [AutonomyLevel] gets registered
  final void Function(AutonomyLevel)? onRegister;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localization.registerAutonomyLevel)),
      body: ChangeNotifierProvider<AutonomyLevelRegisterState>(
        create: (context) {
          return AutonomyLevelRegisterState(onRegister: onRegister);
        },
        child: Consumer<AutonomyLevelRegisterState>(
          builder: (_, state, __) {
            return Form(
              key: state.formKey,
              child: ListView(
                children: [
                  FormTitle(title: localization.register),
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
                      label: localization.register,
                      onPressed: () async {
                        // Validate inputs
                        if (!state.formKey.currentState!.validate()) return;

                        // Try registering
                        final result = await state.register();

                        // Show dialog with register result
                        if (context.mounted) {
                          await registerDialog(context, result);
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
