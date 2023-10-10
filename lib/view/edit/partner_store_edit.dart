import 'dart:async';

import 'package:flutter/material.dart';
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

  /// Get store's current autonomy level
  AutonomyLevel get currentAutonomyLevel => partnerStore.autonomyLevel;

  /// List of all autonomy levels
  final autonomyLevels = <AutonomyLevel>[];

  /// Initialize info
  Future<void> init() async {
    // Initialize controllers
    nameController.text = partnerStore.name;
    cnpjController.text = partnerStore.cnpj;

    // Get all autonomy levels
    final items = await _autonomyLevelUseCase.select();
    autonomyLevels
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  /// Method to submit an edit on the partner store
  Future<String?> edit() async {
    // Check if CNPJ is in valid format
    final cnpj = cnpjController.text;
    if (cnpj.length != 14) {
      return 'Invalid CNPJ format: must be 14 digits';
    } else if (int.tryParse(cnpj) == null) {
      return 'Invalid CNPJ format: must be only numbers';
    }

    // Update info on partner store object
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
    this.onEdit,
    super.key,
  });

  /// Which [User] will be edited
  final User user;

  /// Callback function for when the partner gets edited
  final void Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PartnerStoreEditState>(
      create: (context) {
        return PartnerStoreEditState(
          partnerStore: user.store!,
          onEdit: onEdit,
        );
      },
      child: Consumer<PartnerStoreEditState>(
        builder: (_, state, __) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FormTitle(
                title: 'Edit PartnerStore',
              ),
              const TextHeader(label: 'Name'),
              FormTextEntry(
                label: 'Store name',
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
              ),
              const TextHeader(label: 'Autonomy level'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutonomyLevelDropdown(
                  enabled: user.isAdmin,
                  items: state.autonomyLevels,
                  selected: state.currentAutonomyLevel,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SubmitButton(
                  label: 'Edit',
                  onPressed: () async {
                    // Try editing
                    final result = await state.edit();

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
          );
        },
      ),
    );
  }
}
