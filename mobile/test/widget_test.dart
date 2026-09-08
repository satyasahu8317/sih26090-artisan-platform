import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sih26090_mobile/main.dart';

void main() {
  testWidgets('KalaMitr app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KalaMitrApp(),
      ),
    );

    // Allow the app to build.
    await tester.pumpAndSettle();

    // Verify that the app starts without crashing.
    expect(find.byType(KalaMitrApp), findsOneWidget);
  });
}