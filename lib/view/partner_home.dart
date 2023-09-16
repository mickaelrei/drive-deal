import 'package:flutter/material.dart';

/// Partner Home page widget
class PartnerHomePage extends StatelessWidget {
  /// Constructor
  const PartnerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Partner Home'),
      ),
      body: const Center(
        child: Text('Welcome to Partner Home!'),
      ),
    );
  }
}
