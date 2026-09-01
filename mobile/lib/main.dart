import 'package:flutter/material.dart';
import 'features/onboarding/screens/language_screen.dart';

void main() {
  runApp(const KalaMitrApp());
}

class KalaMitrApp extends StatelessWidget {
  const KalaMitrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KalaMitr',
      home: const LanguageScreen(),
    );
  }
}