import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sih26090_mobile/core/routes/app_routes.dart';
import 'package:sih26090_mobile/core/localization/locale_provider.dart';
import 'package:sih26090_mobile/l10n/generated/app_localizations.dart';




void main() {
  runApp(
    const ProviderScope(
      child: KalaMitrApp(),
    ),
  );
}

class KalaMitrApp extends ConsumerWidget {
  const KalaMitrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'KalaMitr',
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}