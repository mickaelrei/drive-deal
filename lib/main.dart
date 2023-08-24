import 'package:flutter/material.dart';

import 'repositories/autonomy_level_repository.dart';

void main() async {
  runApp(const MyApp());
}

/// Main app
class MyApp extends StatelessWidget {
  /// Constructor
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Teste de listagem de niveis de autonomia
    final autonomyLevelRepository = AutonomyLevelRepository();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Drive Deal')),
        body: Center(
          child: FutureBuilder(
            future: autonomyLevelRepository.select(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Row(
                  children: [
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final autonomyLevel = snapshot.data![index];

                  return ListTile(
                    leading: Text(autonomyLevel.id.toString()),
                    title: Text(autonomyLevel.label),
                    subtitle: Text(
                      'Store percent: ${autonomyLevel.storePercent}\n'
                      'Network percet: ${autonomyLevel.networkPercent}',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
