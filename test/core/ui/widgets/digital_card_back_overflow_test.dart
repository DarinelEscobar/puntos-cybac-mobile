import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/core/ui/widgets/digital_card.dart';
import 'package:puntos_cybac_mobile/features/client_cards/domain/models/client_card.dart';

void main() {
  testWidgets('back side avoids bottom overflow with long manual ID', (
    WidgetTester tester,
  ) async {
    const longMembershipId = 'ffffffff-ffff-4fff-8fff-ffffffffffff';

    final card = ClientCard.fromJson(<String, dynamic>{
      'membership_id': longMembershipId,
      'company_id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      'company_name': 'Glow Clinic',
      'card_uid': '',
      'status': 'ACTIVE',
      'qr_payload': '',
      'points_balance': 480,
      'branding': <String, dynamic>{},
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 340,
                child: DigitalCard(card: card, isBack: true),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text(longMembershipId), findsOneWidget);
  });
}
