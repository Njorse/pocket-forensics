import 'package:flutter_test/flutter_test.dart';

import 'package:first_app/app.dart';

void main() {
  testWidgets('PocketForensics app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PocketForensicsApp());

    // Verify the themed scanner view loads
    expect(find.text('PocketForensics'), findsWidgets);
    expect(find.text('Análisis Forense Digital'), findsOneWidget);
  });
}
