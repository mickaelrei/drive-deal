import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entities/autonomy_level.dart';
import '../../entities/partner_store.dart';
import '../../entities/user.dart';
import '../../repositories/autonomy_level_repository.dart';
import '../../repositories/partner_store_repository.dart';
import '../../repositories/user_repository.dart';
import '../../usecases/autonomy_level_use_case.dart';
import '../../usecases/partner_store_use_case.dart';
import '../../usecases/user_use_case.dart';
import '../../utils/dialogs.dart';
import '../../utils/forms.dart';

/// Provider for register partner store form
class PartnerStoreRegisterState with ChangeNotifier {
  /// Constructor
  PartnerStoreRegisterState({required this.onRegister}) {
    unawaited(init());
  }

  final _formKey = GlobalKey<FormState>();

  /// Form key getter
  GlobalKey<FormState> get formKey => _formKey;

  /// Callback function to when a [PartnerStore] gets registered
  final void Function(PartnerStore)? onRegister;

  /// To insert a new [PartnerStore] in database
  final PartnerStoreUseCase _partnerStoreUseCase = PartnerStoreUseCase(
    const PartnerStoreRepository(),
  );

  /// To get all [AutonomyLevel]s from database
  final AutonomyLevelUseCase _autonomyLevelUseCase = const AutonomyLevelUseCase(
    AutonomyLevelRepository(),
  );

  /// To insert a new [User] in database when the [PartnerStore] gets created
  final UserUseCase _userUseCase = UserUseCase(
    const UserRepository(),
  );

  /// Controller for name field
  final TextEditingController nameController = TextEditingController();

  /// Controller for CNPJ field
  final TextEditingController cnpjController = TextEditingController();

  /// Controller for autonomy level field
  final TextEditingController autonomyLevelController = TextEditingController();

  /// What autonomy level will the store have
  AutonomyLevel? chosenAutonomyLevel;

  /// List of available autonomy levels
  final autonomyLevels = <AutonomyLevel>[];

  /// Method to init variables
  Future<void> init() async {
    // Get all autonomy levels
    final items = await _autonomyLevelUseCase.select();
    autonomyLevels
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  /// Method for register attempt
  Future<String?> register() async {
    // Check if autonomy level was chosen
    if (chosenAutonomyLevel == null) {
      return 'No Autonomy Level selected';
    }

    // Check if CNPJ is in valid format
    final cnpj = cnpjController.text;
    if (cnpj.length != 14) {
      return 'Invalid CNPJ format: must be 14 digits';
    } else if (int.tryParse(cnpj) == null) {
      return 'Invalid CNPJ format: must be only numbers';
    }

    // Generate random 15 chars password
    final password = _userUseCase.generatePassword();

    // Check if store is unique (unique CNPJ)
    final partnerStores = await _partnerStoreUseCase.select();
    for (final store in partnerStores) {
      if (store.cnpj == cnpj) {
        return 'CNPJ is already in use';
      }
    }

    // Create a new partner store and add it to the database
    final partnerStore = PartnerStore(
      cnpj: cnpj,
      name: nameController.text,
      autonomyLevel: chosenAutonomyLevel!,
    );
    await _partnerStoreUseCase.insert(
      partnerStore: partnerStore,
      password: password,
    );

    // If no errors, call onRegister callback and return null meaning success
    if (onRegister != null) {
      onRegister!(partnerStore);
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    cnpjController.dispose();
    autonomyLevelController.dispose();
  }
}

/// Form for registering a partner store
class PartnerStoreRegisterForm extends StatelessWidget {
  /// Constructor
  const PartnerStoreRegisterForm({
    this.navBar,
    required this.onRegister,
    this.theme = UserSettings.defaultAppTheme,
    super.key,
  });

  /// Page navigation bar
  final Widget? navBar;

  /// Callback to be called when a [PartnerStore] gets registered
  final void Function(PartnerStore)? onRegister;

  /// App theme
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PartnerStoreRegisterState>(
      create: (context) {
        return PartnerStoreRegisterState(onRegister: onRegister);
      },
      child: Consumer<PartnerStoreRegisterState>(
        builder: (_, state, __) {
          return Form(
            key: state.formKey,
            child: ListView(
              children: [
                const FormTitle(title: 'Register'),
                const TextHeader(label: 'Name'),
                FormTextEntry(
                  label: 'Name',
                  controller: state.nameController,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Name can\'t be empty';
                    }
                    if (text.length < 3) {
                      return 'Name needs to be at least 3 characters long';
                    }
                    if (text.length > 120) {
                      return 'Name can be at max 120 characters long';
                    }
                    // Valid
                    return null;
                  },
                ),
                const TextHeader(label: 'CNPJ'),
                FormTextEntry(
                  label: 'CNPJ',
                  controller: state.cnpjController,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'CNPJ can\'t be empty';
                    }
                    if (text.length != 14) {
                      return 'CNPJ needs to be exactly 14 characters long'
                          ' (only digits)';
                    }
                    // Valid
                    return null;
                  },
                ),
                const TextHeader(label: 'Autonomy Level'),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: AutonomyLevelDropdown(
                    items: state.autonomyLevels,
                    controller: state.autonomyLevelController,
                    initialSelection: state.chosenAutonomyLevel,
                    onSelected: (autonomyLevel) {
                      state.chosenAutonomyLevel = autonomyLevel;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SubmitButton(
                    label: 'Register',
                    onPressed: () async {
                      // Validate inputs
                      if (!state.formKey.currentState!.validate()) return;

                      // Try registering
                      final result = await state.register();

                      // Show dialog with register result
                      if (context.mounted) {
                        await registerDialog(context, result);
                      }

                      // Return to list page
                      if (result == null) {
                        // ignore: use_build_context_synchronously
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
    );
  }
}
