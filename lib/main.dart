import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() => runApp(const TroiHomNayApp());

class TroiHomNayApp extends StatelessWidget {
  const TroiHomNayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trời Hôm Nay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8833A),
          surface: const Color(0xFFF5F1EA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F1EA),
      ),
      home: const HomeScreen(),
    );
  }
}
