import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glucocare/main.dart';
import 'package:provider/provider.dart';
import 'package:glucocare/providers/health_provider.dart';

void main() {
  testWidgets('GlucoCare app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final provider = HealthProvider();
    await provider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<HealthProvider>.value(
        value: provider,
        child: const GlucoCareApp(),
      ),
    );

    // Pump a few frames
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify main bottom navigation items are rendered
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Food AI'), findsOneWidget);
    expect(find.text('Medicine'), findsOneWidget);
    expect(find.text('Caregiver'), findsOneWidget);
  });
}
