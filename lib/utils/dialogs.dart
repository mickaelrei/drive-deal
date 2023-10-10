import 'package:flutter/material.dart';

/// Show register dialog
Future<void> registerDialog(BuildContext context, String? result) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(result == null ? 'Success' : 'Error'),
        content: Text(result ?? 'Successfully registered!'),
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
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(result == null ? 'Success' : 'Error'),
        content: Text(result ?? 'Successfully edited!'),
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
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Invalid Login'),
        content: const Text('Review your credentials.'),
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
