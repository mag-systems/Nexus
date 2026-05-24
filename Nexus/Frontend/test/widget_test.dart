import 'package:flutter_test/flutter_test.dart';

import 'package:nexus/main.dart';

void main() {
  testWidgets('App shows Nexus Track title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NexusTrackApp());
    await tester.pumpAndSettle();

    // Verify that the app title is present on the InicioScreen.
    expect(find.text('Nexus Track'), findsOneWidget);
  });
}
