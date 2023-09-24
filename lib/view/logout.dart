import 'package:flutter/material.dart';

/// Widget for logout page
class LogoutPage extends StatelessWidget {
  /// Constructor
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('Logout?'),
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
    );
  }
}