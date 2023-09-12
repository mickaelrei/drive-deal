import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/exceptions.dart';
import '../database/partner_store_table.dart';
import '../entities/autonomy_level.dart';
import '../entities/partner_store.dart';

import '../entities/user.dart';
import '../repositories/autonomy_level_repository.dart';
import '../repositories/partner_store_repository.dart';

import '../repositories/user_repository.dart';
import '../usecases/autonomy_level_use_case.dart';
import '../usecases/partner_store_use_case.dart';

import '../usecases/user_use_case.dart';
import 'form_utils.dart';

/// Provider for register store form
class RegisterStoreState with ChangeNotifier {
  /// Constructor
  RegisterStoreState() {
    init();
  }

  /// To insert a new [PartnerStore] in database
  final PartnerStoreUseCase partnerStoreUseCase = PartnerStoreUseCase(
    PartnerStoreRepository(),
  );

  /// To get all [AutonomyLevel]s from database
  final AutonomyLevelUseCase autonomyLevelUseCase = AutonomyLevelUseCase(
    AutonomyLevelRepository(),
  );

  /// To insert a new [User] in database when the [PartnerStore] gets created
  final UserUseCase userUseCase = UserUseCase(
    UserRepository(),
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
  void init() async {
    // Get all autonomy levels
    final items = await autonomyLevelUseCase.select();
    autonomyLevels
      ..clear()
      ..addAll(items);
  }

  /// Method for register attempt
  Future<String?> register() async {
    // Check if autonomy level was chosen
    if (chosenAutonomyLevel == null) {
      return 'No Autonomy Level selected';
    }

    // autonomy level ID shouldn't be null, but check to prevent errors
    if (chosenAutonomyLevel!.id == null) {
      throw EntityNoIdException(
          'Chosen Autonomy Level has no ID: $chosenAutonomyLevel');
    }

    // Check if CNPJ is in valid format
    final cnpj = cnpjController.text;
    if (cnpj.length != 14) {
      return 'Invalid CNPJ format: must be 14 digits';
    } else if (int.tryParse(cnpj) == null) {
      return 'Invalid CNPJ format: must be only numbers';
    }

    // Generate random 15 chars password
    final password = partnerStoreUseCase.generatePassword();

    // Check if store is unique (unique CNPJ)
    final partnerStores = await partnerStoreUseCase.select();
    for (final store in partnerStores) {
      if (store.cnpj == cnpj) {
        return 'CNPJ is already in use';
      }
    }

    // Create a new partner store and add it to the database
    final partnerStore = PartnerStore(
      cnpj: cnpj,
      name: nameController.text,
      autonomyLevelId: chosenAutonomyLevel!.id!,
    );
    await partnerStoreUseCase.insert(partnerStore);

    // Get ID from partnerStore that just got added
    final result = await partnerStoreUseCase.selectFromCNPJ(cnpj);
    if (result.isEmpty) {
      // If result is empty, then no partner store was added with the given cnpj
      // This really shouldn't happen
      throw DatabaseInsertFailException('Insert on table '
          '${PartnerStoreTable.tableName} failed');
    }
    final storeId = result.first.id;

    // Create user with storeId and password and insert to database
    final user = User(
      storeId: storeId,
      password: password,
    );
    await userUseCase.insert(user);

    // If no errors, return null meaning success
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

/// Class for admins for registering a partner store
class RegisterStorePage extends StatelessWidget {
  /// Constructor
  const RegisterStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            'Register',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RegisterStoreForm(),
      ],
    );
  }
}

/// Form for registering a partner store
class RegisterStoreForm extends StatelessWidget {
  /// Constructor
  const RegisterStoreForm({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterStoreState>(
      create: (context) {
        return RegisterStoreState();
      },
      child: Consumer<RegisterStoreState>(
        builder: (_, state, __) {
          return Column(
            children: [
              const FormTextHeader(label: 'Name'),
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
              const FormTextHeader(label: 'CNPJ'),
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
              const FormTextHeader(label: 'Autonomy Level'),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AutonomyLevelDropdown(
                  items: state.autonomyLevels,
                  controller: state.autonomyLevelController,
                  selected: state.chosenAutonomyLevel,
                  onSelected: (autonomyLevel) {
                    state.chosenAutonomyLevel = autonomyLevel;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SubmitButton(
                  label: 'Register',
                  onPressed: () async {
                    // Try registering
                    final result = await state.register();

                    // Show dialog with register result
                    // ignore: use_build_context_synchronously
                    registerDialog(context, result);
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

/// Dropdown for [AutonomyLevel]s
class AutonomyLevelDropdown extends StatelessWidget {
  /// Constructor
  const AutonomyLevelDropdown({
    required this.items,
    required this.controller,
    this.onSelected,
    this.selected,
    super.key,
  });

  /// List of [AutonomyLevel]s
  final List<AutonomyLevel> items;

  /// Controller for text field
  final TextEditingController controller;

  /// Current selected item
  final AutonomyLevel? selected;

  /// Callback for when an item is selected
  final void Function(AutonomyLevel?)? onSelected;

  @override
  Widget build(BuildContext context) {
    // Initialize entries
    final entries = <DropdownMenuEntry<AutonomyLevel>>[];
    for (final item in items) {
      entries.add(DropdownMenuEntry<AutonomyLevel>(
        value: item,
        label: item.label,
      ));
    }

    return DropdownMenu<AutonomyLevel>(
      enableFilter: true,
      enableSearch: true,
      width: MediaQuery.of(context).size.width - 16,
      onSelected: onSelected,
      initialSelection: selected,
      controller: controller,
      dropdownMenuEntries: entries,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

/// Show invalid register dialog
void registerDialog(BuildContext context, String? result) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(result == null ? 'Success' : 'Error'),
        content: Text(result ?? 'Successfully registered!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          )
        ],
      );
    },
  );
}
