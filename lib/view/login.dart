import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/partner_store.dart';
import '../entities/user.dart';

import '../repositories/partner_store_repository.dart';
import '../repositories/user_repository.dart';
import '../usecases/partner_store_use_case.dart';
import '../usecases/user_use_case.dart';

import 'form_utils.dart';

/// Provider for login page
class LoginState with ChangeNotifier {
  /// Use case for [User] operations
  final UserUseCase _userUseCase = UserUseCase(UserRepository());

  /// Use case for [PartnerStore] object
  final PartnerStoreUseCase _partnerStoreUseCase = PartnerStoreUseCase(
    PartnerStoreRepository(),
  );

  /// Name or CNPJ text controller
  final TextEditingController nameOrCnpjController = TextEditingController();

  /// Password text controller
  final TextEditingController passwordController = TextEditingController();

  /// Form key
  final _formKey = GlobalKey<FormState>();

  /// Form key getter
  GlobalKey<FormState> get formKey => _formKey;

  /// Method for login attempt
  Future<LoginType> login() async {
    // User object that will be either an admin or normal user (or null
    // in case of invalid login)
    late User? user;

    // Check if login was a name or a CNPJ
    final loginText = nameOrCnpjController.text;
    if (_userUseCase.isCNPJ(loginText)) {
      // Its a CNPJ
      // Try to find store with same CNPJ
      final store = await _partnerStoreUseCase.selectFromCNPJ(loginText);
      if (store == null) {
        // No store with this CNPJ
        return LoginType.invalid;
      }

      // Get normal user
      user = await _userUseCase.getUser(
        storeId: store.id!,
        password: passwordController.text,
      );
    } else {
      // Its a name, so get admin user
      user = await _userUseCase.getAdmin(
        name: loginText,
        password: passwordController.text,
      );
    }

    // Invalid user
    if (user == null) {
      return LoginType.invalid;
    }

    // Valid user
    if (user.isAdmin) {
      return LoginType.admin;
    } else {
      return LoginType.nonAdmin;
    }
  }

  @override
  void dispose() {
    super.dispose();

    nameOrCnpjController.dispose();
    passwordController.dispose();
  }
}

/// Login page widget
class LoginPage extends StatelessWidget {
  /// Constructor
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drive Deal'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            LoginForm(),
          ],
        ),
      ),
    );
  }
}

/// Form for user registering
class LoginForm extends StatelessWidget {
  /// Constructor
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginState>(
      create: (context) {
        return LoginState();
      },
      child: Consumer<LoginState>(
        builder: (_, state, __) {
          return Form(
            key: state.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FormTextHeader(label: 'Name or CNPJ'),
                FormTextEntry(
                  controller: state.nameOrCnpjController,
                  label: 'Name or CNPJ',
                  prefixIcon: Icons.person,
                ),
                const FormTextHeader(label: 'Password'),
                FormTextEntry(
                  controller: state.passwordController,
                  hidden: true,
                  label: 'Password',
                  prefixIcon: Icons.password,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 15,
                  ),
                  child: SubmitButton(
                    label: 'Enter',
                    onPressed: () async {
                      if (!state.formKey.currentState!.validate()) return;

                      // In case of valid entries, try to submit
                      final loginType = await state.login();
                      switch (loginType) {
                        case LoginType.invalid:
                          // ignore: use_build_context_synchronously
                          invalidLoginDialog(context);
                          break;
                        case LoginType.admin:
                        case LoginType.nonAdmin:
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushReplacementNamed(
                            '/home',
                            arguments: {
                              'isAdmin': loginType == LoginType.admin
                            },
                          );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Show invalid login dialog
void invalidLoginDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Invalid Login'),
        content: const Text('Review your credentials.'),
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

/// Enum for type of login
enum LoginType {
  /// Admin login
  admin,

  /// Non-admin (partner) login
  nonAdmin,

  /// Invalid login (incorrect name or password)
  invalid,
}
