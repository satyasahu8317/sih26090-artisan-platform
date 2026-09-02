import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sih26090_mobile/core/routes/app_routes.dart';



void main() {
  runApp(
    const ProviderScope(
      child: KalaMitrApp(),
    ),
  );
}

class KalaMitrApp extends StatelessWidget {
  const KalaMitrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'KalaMitr',
      routerConfig: appRouter,
    );
  }
}