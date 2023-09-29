import 'package:flutter/material.dart';

/// Show a confirm dialog
Future<bool> confirmDialog(BuildContext context) async {
  var confirmed = false;

  // Confirm button
  final confirmButton = TextButton.icon(
    onPressed: () {
      confirmed = true;
      Navigator.of(context).pop();
    },
    icon: const Icon(Icons.check),
    label: const Text('Confirm'),
  );

  // Decline button
  final declineButton = TextButton.icon(
    onPressed: () {
      confirmed = false;
      Navigator.of(context).pop();
    },
    icon: const Icon(Icons.cancel),
    label: const Text('Decline'),
  );

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        actions: [declineButton, confirmButton],
        title: const Text('Are you sure?'),
        content: const Text(
          'Deleting a vehicle will also delete'
          ' all existent sales related to it.',
        ),
      );
    },
  );

  return confirmed;
}

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
            child: const Text('Ok'),
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
            child: const Text('Ok'),
          )
        ],
      );
    },
  );
}
