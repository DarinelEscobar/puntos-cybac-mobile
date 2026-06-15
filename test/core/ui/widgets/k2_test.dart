import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/core/config/q7.dart';
import 'package:puntos_cybac_mobile/core/ui/widgets/k2.dart';

void main() {
  testWidgets('reveals q7 after a three pointer hold', (
    WidgetTester tester,
  ) async {
    final opened = <Uri>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: K2(
            d: const Duration(milliseconds: 100),
            x: (uri) async {
              opened.add(uri);
              return true;
            },
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    final a = await tester.createGesture(pointer: 1);
    final b = await tester.createGesture(pointer: 2);
    final c = await tester.createGesture(pointer: 3);

    await a.down(const Offset(40, 40));
    await b.down(const Offset(80, 40));
    await c.down(const Offset(120, 40));

    await tester.pump(const Duration(milliseconds: 99));
    expect(find.text(Q7.v.t), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text(Q7.v.t), findsOneWidget);
    expect(find.text('${Q7.v.p} ${Q7.v.n}'), findsOneWidget);

    await tester.tap(find.text(Q7.v.l.first.toString()));
    expect(opened, contains(Q7.v.l.first));

    await a.up();
    await b.up();
    await c.up();
  });
}
