import 'package:flutter/material.dart';

import '../../entities/partner_store.dart';
import '../../entities/user.dart';
import '../../utils/forms.dart';

/// Widget for info about [PartnerStore]
class AdminInfoPage extends StatelessWidget {
  /// Constructor
  const AdminInfoPage({
    required this.user,
    this.navBar,
    this.onUserEdit,
    this.theme = UserSettings.defaultAppTheme,
    super.key,
  });

  /// Reference to [User] object
  final User user;

  /// Page navigation bar
  final Widget? navBar;

  /// Optional callback for when the [PartnerStore] gets edited
  final void Function()? onUserEdit;

  /// Theme
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Admin Home'),
      ),
      bottomNavigationBar: navBar,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Go in edit route
          await Navigator.of(context).pushNamed(
            '/user_edit',
            arguments: {
              'user': user,
              'theme': theme,
              'on_edit': onUserEdit,
            },
          );
        },
        child: const Icon(Icons.edit),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: TextHeader(label: 'User name'),
          ),
          InfoText(user.name!),
          const TextHeader(label: 'Total network profit'),
          const InfoText('TODO'),
        ],
      ),
    );
  }
}
