import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../entities/autonomy_level.dart';
import '../../entities/partner_store.dart';
import '../../entities/user.dart';
import '../../repositories/autonomy_level_repository.dart';
import '../../repositories/partner_store_repository.dart';
import '../../usecases/autonomy_level_use_case.dart';
import '../../usecases/partner_store_use_case.dart';
import '../../utils/dialogs.dart';
import '../../utils/forms.dart';

/// Provider for partner store edit page
class PartnerStoreEditState with ChangeNotifier {
  /// Constructor
  PartnerStoreEditState({
    required this.partnerStore,
    this.onEdit,
  }) {
    unawaited(init());
  }

  /// Reference to partner store object
  final PartnerStore partnerStore;

  /// Callback function for when the partner gets edited
  final void Function()? onEdit;

  final _formKey = GlobalKey<FormState>();

  /// Form key getter
  GlobalKey<FormState> get formKey => _formKey;

  /// To make operations on [PartnerStore] table
  final _partnerStoreUseCase = PartnerStoreUseCase(
    const PartnerStoreRepository(),
  );

  /// To get all [AutonomyLevel]s from database
  final _autonomyLevelUseCase = const AutonomyLevelUseCase(
    AutonomyLevelRepository(),
  );

  /// Controller for name field
  final nameController = TextEditingController();

  /// Controller for CNPJ field
  final cnpjController = TextEditingController();

  /// Currently selected autonomy level
  late AutonomyLevel _selectedAutonomyLevel;

  /// Get current selected autonomy level
  AutonomyLevel get selectedAutonomyLevel => _selectedAutonomyLevel;

  /// List of all autonomy levels
  final autonomyLevels = <AutonomyLevel>[];

  /// Initialize info
  Future<void> init() async {
    // Initialize controllers
    nameController.text = partnerStore.name;
    cnpjController.text = partnerStore.cnpj;

    // Initialize current autonomy level
    _selectedAutonomyLevel = partnerStore.autonomyLevel;

    // Get all autonomy levels
    final items = await _autonomyLevelUseCase.select();
    autonomyLevels
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  /// Method to update selected autonomy level
  void onAutonomyLevelChanged(AutonomyLevel? autonomyLevel) {
    _selectedAutonomyLevel = autonomyLevel!;
  }

  /// Method to submit an edit on the partner store
  Future<String?> edit(BuildContext context) async {
    final localization = AppLocalizations.of(context)!;

    // Check if CNPJ is in valid format
    final cnpj = cnpjController.text;
    if (cnpj.length != 14 || int.tryParse(cnpj) == null) {
      return localization.invalidCnpj;
    }
    // Update info on partner store object
    partnerStore.autonomyLevel = _selectedAutonomyLevel;
    partnerStore.name = nameController.text;
    partnerStore.cnpj = cnpj;

    // Update in database
    await _partnerStoreUseCase.update(partnerStore);

    // Call onEdit callback
    if (onEdit != null) {
      onEdit!();
    }

    // Success
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    cnpjController.dispose();
  }
}

/// Form for [PartnerStore] editing
class PartnerStoreEditPage extends StatelessWidget {
  /// Constructor
  const PartnerStoreEditPage({
    required this.user,
    required this.partnerStore,
    this.onEdit,
    super.key,
  });

  /// To know if the user is an admin or not
  final User user;

  /// Which store is getting edited
  final PartnerStore partnerStore;

  /// Callback function for when the partner gets edited
  final void Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<PartnerStoreEditState>(
      create: (context) {
        return PartnerStoreEditState(
          partnerStore: partnerStore,
          onEdit: onEdit,
        );
      },
      child: Consumer<PartnerStoreEditState>(
        builder: (_, state, __) {
          return Form(
            key: state.formKey,
            child: ListView(
              children: [
                FormTitle(title: localization.edit),
                TextHeader(label: localization.storeName),
                FormTextEntry(
                  label: localization.storeName,
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
                ),
                TextHeader(label: localization.autonomyLevel(1)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutonomyLevelDropdown(
                    onSelected: state.onAutonomyLevelChanged,
                    enabled: user.isAdmin,
                    items: state.autonomyLevels,
                    initialSelection: state.selectedAutonomyLevel,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SubmitButton(
                    label: localization.edit,
                    onPressed: () async {
                      // Validate inputs
                      if (!state.formKey.currentState!.validate()) return;

                      // Try editing
                      final result = await state.edit(context);

                      // Show dialog with edit result
                      if (context.mounted) {
                        await editDialog(context, result);
                      }

                      // Exit from edit page
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
