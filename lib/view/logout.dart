import 'package:flutter/material.dart';

/// Widget for logout page
class LogoutPage extends StatelessWidget {
  /// Constructor
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: const Text(
          'Logout?',
          style: TextStyle(fontSize: 20),
        ),
        onPressed: () async {
          await Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
    );
  }
}
