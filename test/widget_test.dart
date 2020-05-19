import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpAndSettle(Duration(seconds: 10));

    await tester.pump();
  });
}
