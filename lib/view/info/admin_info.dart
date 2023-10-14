import 'package:flutter/material.dart';

import '../../entities/partner_store.dart';
import '../../entities/user.dart';
import '../../utils/formats.dart';
import '../../utils/forms.dart';

/// Widget for info about [PartnerStore]
class AdminInfoPage extends StatelessWidget {
  /// Constructor
  const AdminInfoPage({
    required this.user,
    this.navBar,
    this.onUserEdit,
    this.totalNetworkProfit,
    this.theme = UserSettings.defaultAppTheme,
    super.key,
  });

  /// Reference to [User] object
  final User user;

  /// Page navigation bar
  final Widget? navBar;

  /// Optional callback for when the [PartnerStore] gets edited
  final void Function()? onUserEdit;

  /// Total network profit
  final double? totalNetworkProfit;

  /// Theme
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Admin Home'),
        actions: [
          IconButton(
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
            icon: const Icon(Icons.edit),
          )
        ],
      ),
      bottomNavigationBar: navBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: TextHeader(label: 'User name'),
          ),
          InfoText(user.name!),
          const TextHeader(label: 'Total network profit'),
          InfoText(
            totalNetworkProfit == null
                ? 'Loading...'
                : formatPrice(totalNetworkProfit!),
          ),
        ],
      ),
    );
  }
}
