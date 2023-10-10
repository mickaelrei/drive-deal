import 'package:flutter/material.dart';

/// Widget for unknown page in home BottomNavigationBar
class UnknownPage extends StatelessWidget {
  /// Constructor
  const UnknownPage({this.navBar, super.key});

  /// Page navigation bar
  final Widget? navBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Unknown Page'),
      ),
      bottomNavigationBar: navBar,
      body: const Center(
        child: Text('Error: Unknown page'),
      ),
    );
  }
}
