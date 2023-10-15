import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../usecases/user_use_case.dart';
import '../../utils/dialogs.dart';
import '../../utils/forms.dart';

/// Provider for partner store edit page
class UserEditState with ChangeNotifier {
  /// Constructor
  UserEditState({
    required this.user,
    this.onEdit,
  }) {
    unawaited(init());
  }

  /// Reference to partner store object
  final User user;

  /// Callback function for when the partner gets edited
  final void Function()? onEdit;

  final _formKey = GlobalKey<FormState>();

  /// Form key getter
  GlobalKey<FormState> get formKey => _formKey;

  /// To make operations on [User] table
  final _userUseCase = UserUseCase(
    const UserRepository(),
  );

  /// Controller for name field
  final nameController = TextEditingController();

  /// Controller for password field
  final passwordController = TextEditingController();

  /// Initialize info
  Future<void> init() async {
    // Initialize controllers
    nameController.text = user.name ?? '';
    passwordController.text = user.password;

    notifyListeners();
  }

  /// Method to submit an edit on the partner store
  Future<String?> edit(BuildContext context) async {
    final localization = AppLocalizations.of(context)!;

    // Update info on partner store object
    user.name = nameController.text;
    user.password = passwordController.text;

    // Try to update in database
    final success = await _userUseCase.update(user);
    if (!success) {
      return localization.userEditFailed;
    }

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
    passwordController.dispose();
  }
}

/// Form for [User] editing
class UserEditPage extends StatelessWidget {
  /// Constructor
  const UserEditPage({
    required this.user,
    this.onEdit,
    super.key,
  });

  /// Which [User] will be edited
  final User user;

  /// Optional callback for user edit
  final void Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<UserEditState>(
      create: (context) {
        return UserEditState(
          user: user,
          onEdit: onEdit,
        );
      },
      child: Consumer<UserEditState>(
        builder: (_, state, __) {
          return Form(
            key: state.formKey,
            child: ListView(
              children: [
                FormTitle(title: localization.edit),
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
                    return null;
                  },
                ),
                TextHeader(label: localization.password),
                FormTextEntry(
                  label: localization.password,
                  controller: state.passwordController,
                  hidden: true,
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
