import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget for unknown page in home BottomNavigationBar
class UnknownPage extends StatelessWidget {
  /// Constructor
  const UnknownPage({this.navBar, super.key});

  /// Page navigation bar
  final Widget? navBar;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('?'),
      ),
      bottomNavigationBar: navBar,
      body: Center(
        child: Text(localization.unknownPage),
      ),
    );
  }
}
