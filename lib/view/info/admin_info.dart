import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.home),
        actions: [
          IconButton(
            onPressed: () async {
              // Go in edit route
              await context.pushNamed(
                'user_edit',
                extra: {
                  'user': user,
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
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextHeader(label: localization.userName),
          ),
          InfoText(user.name!),
          TextHeader(label: localization.totalNetworkProfit),
          InfoText(
            totalNetworkProfit == null
                ? localization.loading
                : formatPrice(totalNetworkProfit!),
          ),
        ],
      ),
    );
  }
}
