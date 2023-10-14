import 'dart:async';

import 'package:flutter/material.dart';
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
  Future<String?> edit() async {
    // Update info on partner store object
    user.name = nameController.text;
    user.password = passwordController.text;

    // Try to update in database
    final success = await _userUseCase.update(user);
    if (!success) {
      return 'Failed to edit user. Name needs to be unique';
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
    return ChangeNotifierProvider<UserEditState>(
      create: (context) {
        return UserEditState(
          user: user,
          onEdit: onEdit,
        );
      },
      child: Consumer<UserEditState>(
        builder: (_, state, __) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FormTitle(title: 'Edit'),
              const TextHeader(label: 'Name'),
              FormTextEntry(
                label: 'Name',
                controller: state.nameController,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Name can\'t be blank.';
                  }
                  if (text.length < 3) {
                    return 'Name needs at least 3 characters.';
                  }
                  return null;
                },
              ),
              const TextHeader(label: 'Password'),
              FormTextEntry(
                label: 'Password',
                controller: state.passwordController,
                hidden: true,
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
