import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hfcms_frontend/app/app.dart';

void main() {
  testWidgets('HFCMS smoke test - renders title and status badge', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HfcmsApp(),
      ),
    );

    // Verify title text renders
    expect(find.text('Hostel Facility Complaint Management System'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
  });
}
