import 'package:flutter_test/flutter_test.dart';
import 'package:ipma_apk/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IpmaApp());
    expect(find.byType(IpmaApp), findsOneWidget);
  });
}
