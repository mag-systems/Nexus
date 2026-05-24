import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/inicio_screen.dart';

void main() {
  runApp(const NexusTrackApp());
}

class NexusTrackApp extends StatelessWidget {
  const NexusTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus Track',
      theme: NexusTheme.dark,
      home: const InicioScreen(),
    );
  }
}
