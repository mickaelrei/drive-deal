import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Show register dialog
Future<void> registerDialog(BuildContext context, String? result) async {
  final localization = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(result == null ? localization.success : localization.error),
        content: Text(result ?? localization.registerSuccess),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      );
    },
  );
}

/// Show edit dialog
Future<void> editDialog(BuildContext context, String? result) async {
  final localization = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(result == null ? localization.success : localization.error),
        content: Text(result ?? localization.editSuccess),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      );
    },
  );
}

/// Show invalid login dialog
Future<void> invalidLoginDialog(BuildContext context) async {
  final localization = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(localization.invalidLogin),
        content: Text(localization.reviewCredentials),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      );
    },
  );
}
