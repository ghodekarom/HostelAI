import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hfcms_frontend/app/app.dart';
import 'package:hfcms_frontend/core/widgets/status_badge.dart';
import 'package:hfcms_frontend/core/widgets/priority_badge.dart';
import 'package:hfcms_frontend/core/widgets/ai_badge.dart';

void main() {
  group('HFCMS Core Widget Tests', () {
    testWidgets('renders StatusBadge with icon and status text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'OPERATOR_REVIEW'),
          ),
        ),
      );

      expect(find.text('OPERATOR REVIEW'), findsOneWidget);
      expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
    });

    testWidgets('renders PriorityBadge and SeverityBadge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PriorityBadge(priority: 'P1'),
                SeverityBadge(severity: 'CRITICAL'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('P1'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);
    });

    testWidgets('renders AiBadge with purple styling and sparkle icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiBadge(label: 'AI Suggestion'),
          ),
        ),
      );

      expect(find.text('AI Suggestion'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('HfcmsApp smoke test - mounts and renders portal home', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: HfcmsApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('HFCMS'), findsWidgets);
      expect(find.text('Student Portal'), findsOneWidget);
      expect(find.text('Operator Room'), findsOneWidget);
      expect(find.text('Technician Tasks'), findsOneWidget);
      expect(find.text('Admin Hub'), findsOneWidget);
    });
  });
}
