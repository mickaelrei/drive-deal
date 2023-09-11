import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/autonomy_level.dart';
import '../entities/partner_store.dart';

import '../repositories/partner_store_repository.dart';

import '../usecases/partner_store_use_case.dart';

import 'form_utils.dart';

/// Provider for register store form
class RegisterStoreState with ChangeNotifier {
  /// For [PartnerStore] operations
  final PartnerStoreUseCase partnerStoreUseCase = PartnerStoreUseCase(
    PartnerStoreRepository(),
  );

  /// Controller for name field
  final TextEditingController nameController = TextEditingController();

  /// Controller for CNPJ field
  final TextEditingController cnpjController = TextEditingController();

  /// What autonomy level will the store have
  AutonomyLevel? autonomyLevel;

  /// Method for register attempt
  Future<void> register() async {
    print('Trying to register partner store');
    // TODO: Generate random 15 chars password

    // TODO: Create a new [PartnerStore] and add it to the database

    // TODO: Check if store is unique (unique CNPJ)

    // TODO: Create User with given name, or create a new PartnerLoginPage
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    cnpjController.dispose();
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
        builder: (context, state, child) {
          return Column(
            children: [
              const FormTextHeader(label: 'Store Name'),
              FormTextEntry(
                label: 'Name',
                controller: state.nameController,
              ),
              const FormTextHeader(label: 'Store CNPJ'),
              FormTextEntry(
                label: 'CNPJ',
                controller: state.cnpjController,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SubmitButton(
                  label: 'Register',
                  onPressed: () async {
                    await state.register();
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
