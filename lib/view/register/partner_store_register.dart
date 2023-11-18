import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  Future<String?> register(BuildContext context) async {
    final localization = AppLocalizations.of(context)!;

    // Check if autonomy level was chosen
    if (chosenAutonomyLevel == null) {
      return localization.noAutonomyLevel;
    }

    // Check if CNPJ is in valid format
    final cnpj = cnpjController.text;
    if (cnpj.length != 14 || int.tryParse(cnpj) == null) {
      return localization.invalidCnpj;
    }

    // Generate random 15 chars password
    final password = _userUseCase.generatePassword();

    // Check if store is unique (unique CNPJ)
    final partnerStores = await _partnerStoreUseCase.select();
    for (final store in partnerStores) {
      if (store.cnpj == cnpj) {
        return localization.cnpjInUse;
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
    required this.onRegister,
    super.key,
  });

  /// Callback to be called when a [PartnerStore] gets registered
  final void Function(PartnerStore)? onRegister;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localization.registerPartnerStore)),
      body: ChangeNotifierProvider<PartnerStoreRegisterState>(
        create: (context) {
          return PartnerStoreRegisterState(onRegister: onRegister);
        },
        child: Consumer<PartnerStoreRegisterState>(
          builder: (_, state, __) {
            return Form(
              key: state.formKey,
              child: ListView(
                children: [
                  FormTitle(title: localization.register),
                  TextHeader(label: localization.name),
                  FormTextEntry(
                    label: localization.name,
                    controller: state.nameController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return localization.nameNotEmpty;
                      }
                      if (text.length < 3) {
                        return localization.nameMinSize(3);
                      }
                      if (text.length > 120) {
                        return localization.nameMaxSize(120);
                      }
                      // Valid
                      return null;
                    },
                  ),
                  TextHeader(label: localization.cnpj),
                  FormTextEntry(
                    label: localization.cnpj,
                    controller: state.cnpjController,
                    validator: (text) {
                      if (text == null || text.isEmpty || text.length != 14) {
                        return localization.invalidCnpj;
                      }
                      // Valid
                      return null;
                    },
                  ),
                  TextHeader(label: localization.autonomyLevel(1)),
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
                      label: localization.register,
                      onPressed: () async {
                        // Validate inputs
                        if (!state.formKey.currentState!.validate()) return;

                        // Try registering
                        final result = await state.register(context);

                        // Show dialog with register result
                        if (context.mounted) {
                          await registerDialog(context, result);
                        }

                        // Return to list page
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
