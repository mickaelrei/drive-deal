import 'package:flutter/material.dart';

/// Widget for logout page
class LogoutPage extends StatelessWidget {
  /// Constructor
  const LogoutPage({this.navBar, super.key});

  /// Page navigation bar
  final Widget? navBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logout')),
      bottomNavigationBar: navBar,
      body: Center(
        child: TextButton(
          child: const Text(
            'Logout?',
            style: TextStyle(fontSize: 20),
          ),
          onPressed: () async {
            await Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
      ),
    );
  }
}
