import 'package:flutter_test/flutter_test.dart';
import 'package:foodie/main.dart';
import 'package:foodie/screens/get_start_screen/get_started_screen.dart';

void main() {
  testWidgets('App start smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(startScreen: GetStartedScreen()));
    expect(find.byType(GetStartedScreen), findsOneWidget);
  });
}