import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/core/theme/app_theme.dart';
import 'package:puntos_cybac_mobile/core/ui/widgets/debug_build_badge.dart';

void main() {
  testWidgets('App theme smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => Stack(
          children: [
            child ?? const SizedBox.shrink(),
            const Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                minimum: EdgeInsets.only(top: 12, right: 12),
                child: DebugBuildBadge(),
              ),
            ),
          ],
        ),
        home: const Scaffold(body: Center(child: Text('Puntos CYBAC'))),
      ),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(find.text('Puntos CYBAC'), findsOneWidget);
    expect(find.text(DebugBuildBadge.label), findsOneWidget);
    expect(materialApp.theme?.useMaterial3, isTrue);
    expect(materialApp.theme?.colorScheme.primary, AppTheme.primary);
  });
}
