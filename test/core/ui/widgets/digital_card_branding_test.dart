import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/core/ui/widgets/digital_card.dart';
import 'package:puntos_cybac_mobile/features/client_cards/domain/models/client_card.dart';

void main() {
  group('DigitalCard branding palette', () {
    testWidgets('uses explicit primary and secondary when both are provided', (
      WidgetTester tester,
    ) async {
      final card = _cardWithBranding(
        colorPrimary: '#0F172A',
        colorSecondary: '#F8FAFC',
        colorAccent: '#F97316',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 360, child: DigitalCard(card: card)),
            ),
          ),
        ),
      );

      final gradient = _extractCardGradient(tester);
      expect(gradient.colors.first, const Color(0xFF0F172A));
      expect(gradient.colors.last, const Color(0xFFF8FAFC));
    });

    testWidgets('derives secondary when only one branding color is provided', (
      WidgetTester tester,
    ) async {
      final card = _cardWithBranding(colorPrimary: '#0F172A');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 360, child: DigitalCard(card: card)),
            ),
          ),
        ),
      );

      final gradient = _extractCardGradient(tester);
      expect(gradient.colors.first, const Color(0xFF0F172A));
      expect(gradient.colors.last, isNot(const Color(0xFF111621)));
      expect(gradient.colors.last, isNot(gradient.colors.first));
    });

    testWidgets(
      'derives distinct companion color when primary and secondary are equal',
      (WidgetTester tester) async {
        final card = _cardWithBranding(
          colorPrimary: '#0F172A',
          colorSecondary: '#0F172A',
          colorAccent: '#0F172A',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(width: 360, child: DigitalCard(card: card)),
              ),
            ),
          ),
        );

        final gradient = _extractCardGradient(tester);
        expect(gradient.colors.first, const Color(0xFF0F172A));
        expect(gradient.colors.last, isNot(gradient.colors.first));
      },
    );
  });
}

ClientCard _cardWithBranding({
  String? colorPrimary,
  String? colorSecondary,
  String? colorAccent,
}) {
  return ClientCard.fromJson(<String, dynamic>{
    'membership_id': 'membership-1',
    'company_id': 'company-1',
    'company_name': 'Aurora',
    'card_uid': 'CARD-0010',
    'status': 'ACTIVE',
    'qr_payload': 'CARD-0010',
    'points_balance': 250,
    'branding': <String, dynamic>{
      'color_primary': colorPrimary,
      'color_secondary': colorSecondary,
      'color_accent': colorAccent,
    },
  });
}

LinearGradient _extractCardGradient(WidgetTester tester) {
  final cardFinder = find.byWidgetPredicate((widget) {
    if (widget is! Container) return false;
    final decoration = widget.decoration;
    return decoration is BoxDecoration && decoration.gradient is LinearGradient;
  });

  final cardContainer = tester.widget<Container>(cardFinder.first);
  final cardDecoration = cardContainer.decoration! as BoxDecoration;
  return cardDecoration.gradient! as LinearGradient;
}
