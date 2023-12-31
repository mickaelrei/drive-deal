import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../entities/user.dart';
import '../repositories/partner_store_repository.dart';
import '../repositories/user_repository.dart';
import '../usecases/partner_store_use_case.dart';
import '../usecases/user_use_case.dart';
import '../utils/dialogs.dart';
import '../utils/forms.dart';
import 'main_state.dart';

/// Provider for login page
class LoginState with ChangeNotifier {
  final UserUseCase _userUseCase = UserUseCase(const UserRepository());

  final PartnerStoreUseCase _partnerStoreUseCase = PartnerStoreUseCase(
    const PartnerStoreRepository(),
  );

  /// Name or CNPJ text controller
  final TextEditingController nameOrCnpjController = TextEditingController(
    text: '12345678901234',
  );

  /// Password text controller
  final TextEditingController passwordController = TextEditingController(
    text: 'user123',
  );

  final _formKey = GlobalKey<FormState>();

  /// Form key getter
  GlobalKey<FormState> get formKey => _formKey;

  /// Method to set last login
  void setLastLogin(String? lastLogin) {
    nameOrCnpjController.text = lastLogin ?? '';
  }

  /// Method for login attempt
  Future<User?> login() async {
    // User object that will be either an admin or normal user (or null
    // in case of invalid login)
    late final User? user;

    // In case no login text is provided
    final loginText = nameOrCnpjController.text;

    // Check if login was a name or a CNPJ
    if (_userUseCase.isCNPJ(loginText)) {
      // Its a CNPJ
      // Try to find store with same CNPJ
      final store = await _partnerStoreUseCase.selectByCNPJ(loginText);
      if (store == null) {
        // No store with this CNPJ
        return null;
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

    // Return user object
    return user;
  }

  /// Method to clear form inputs
  void clear() {
    nameOrCnpjController.clear();
    passwordController.clear();
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Drive Deal'),
        centerTitle: true,
      ),
      body: const Center(
        child: LoginForm(),
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
    final localization = AppLocalizations.of(context)!;
    final mainState = Provider.of<MainState>(context, listen: false);

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
                const FormTitle(title: 'Login'),
                TextHeader(label: localization.nameOrCnpj),
                FormTextEntry(
                  controller: state.nameOrCnpjController,
                  label: localization.nameOrCnpj,
                  prefixIcon: Icons.person,
                ),
                TextHeader(label: localization.password),
                FormTextEntry(
                  controller: state.passwordController,
                  hidden: true,
                  label: localization.password,
                  prefixIcon: Icons.password,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 15,
                  ),
                  child: SubmitButton(
                    label: localization.enter,
                    onPressed: () async {
                      if (!state.formKey.currentState!.validate()) return;

                      // In case of valid entries, try to submit
                      final user = await state.login();

                      // Clear inputs
                      state.clear();

                      // If user is null, login was invalid
                      if (user == null) {
                        if (context.mounted) {
                          await invalidLoginDialog(context);
                        }
                        return;
                      }

                      // User is valid, set logged user in main state
                      await mainState.setLoggedUser(user);

                      // Go to home page
                      if (context.mounted) {
                        await Navigator.of(context).pushNamed(
                          '/home',
                          arguments: {
                            'user': user,
                          },
                        );

                        // After returning to login page, set last login
                        state.setLastLogin(mainState.lastLogin);
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
