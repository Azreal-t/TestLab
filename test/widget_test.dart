import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testlab/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Dio Test Lab smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DioTestLabApp());

    // Wait for async SharedPreferences initialization to complete
    await tester.pumpAndSettle();

    // Verify that the title and basic layout is rendered.
    expect(find.text('Test Lab'), findsOneWidget);
    expect(find.text('Configurar Requisição'), findsOneWidget);
  });
}
