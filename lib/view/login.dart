import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../usecases/user_use_case.dart';

/// Provider for login page
class LoginState with ChangeNotifier {
  /// Use case for [User] operations
  final UserUseCase _userUseCase = UserUseCase(UserRepository());

  /// Name text controller
  final TextEditingController nameController = TextEditingController();

  /// Password text controller
  final TextEditingController passwordController = TextEditingController();

  /// Form key
  final _formKey = GlobalKey<FormState>();

  /// Form key getter
  GlobalKey<FormState> get formKey => _formKey;

  /// Method for submit attempt
  Future<LoginType> submit() async {
    final user = await _userUseCase.getUser(
      name: nameController.text,
      password: passwordController.text,
    );

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

    nameController.dispose();
    passwordController.dispose();
  }
}

/// Login page widget
class LoginPage extends StatelessWidget {
  /// Constructor
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return LoginState();
      },
      child: Scaffold(
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
    return Consumer<LoginState>(
      builder: (context, state, child) {
        return Form(
          key: state.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              FormTextEntry(
                controller: state.nameController,
                label: 'Name',
                prefixIcon: Icons.person,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0, top: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              FormTextEntry(
                controller: state.passwordController,
                hidden: true,
                label: 'Password',
                prefixIcon: Icons.password,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
                child: ElevatedButton(
                  onPressed: () async {
                    if (!state.formKey.currentState!.validate()) return;

                    // In case of valid entries, try to submit
                    final loginType = await state.submit();
                    switch (loginType) {
                      case LoginType.invalid:
                        // ignore: use_build_context_synchronously
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
                        break;
                      case LoginType.admin:
                      case LoginType.nonAdmin:
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushNamed(
                          '/home',
                          arguments: {'isAdmin': loginType == LoginType.admin},
                        );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      'ENTER',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Text entry for a Form
class FormTextEntry extends StatelessWidget {
  /// Constructor
  const FormTextEntry({
    required this.label,
    required this.controller,
    this.prefixIcon,
    this.validator,
    this.hidden = false,
    super.key,
  });

  /// What is this form entry supposed to represent
  final String label;

  /// Search text controller
  final TextEditingController controller;

  /// Optional prefix icon
  final IconData? prefixIcon;

  /// Optional validator function
  final String? Function(String?)? validator;

  /// Whether the written text should be hidden (like for a password)
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        validator: validator,
        controller: controller,
        obscureText: hidden,
        decoration: InputDecoration(
          // labelText: label,
          hintText: label,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
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
