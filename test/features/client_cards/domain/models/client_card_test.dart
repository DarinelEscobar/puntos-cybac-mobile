import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/features/client_cards/domain/models/client_card.dart';

void main() {
  group('ClientCard QR payload resolution', () {
    test('uses API qr_payload when it is valid', () {
      final card = ClientCard.fromJson(_cardJson(qrPayload: 'CARD-0001'));

      expect(card.displayId, 'CARD-0001');
      expect(card.qrDataForDisplay, 'CARD-0001');
    });

    test('falls back to card_uid when qr_payload is null', () {
      final card = ClientCard.fromJson(
        _cardJson(cardUid: 'CARD-8821', qrPayload: null),
      );

      expect(card.displayId, 'CARD-8821');
      expect(card.qrDataForDisplay, 'CARD-8821');
    });

    test('falls back to membership_id when card_uid is empty', () {
      final card = ClientCard.fromJson(
        _cardJson(cardUid: '   ', membershipId: 'membership-77', qrPayload: ''),
      );

      expect(card.displayId, 'membership-77');
      expect(card.qrDataForDisplay, 'membership-77');
    });

    test('falls back to ID when qr_payload exceeds QR capacity', () {
      final card = ClientCard.fromJson(
        _cardJson(
          cardUid: 'CARD-3322',
          qrPayload: List.filled(4000, 'A').join(),
        ),
      );

      expect(card.qrDataForDisplay, 'CARD-3322');
    });

    test('serializes map qr_payload values safely', () {
      final card = ClientCard.fromJson(
        _cardJson(
          qrPayload: <String, dynamic>{
            'card_id': 'CARD-1000',
            'company_id': 'company-1',
          },
        ),
      );

      expect(card.qrDataForDisplay, contains('"card_id":"CARD-1000"'));
    });
  });
}

Map<String, dynamic> _cardJson({
  String membershipId = 'membership-1',
  String companyId = 'company-1',
  String cardUid = 'CARD-0001',
  dynamic qrPayload = 'CARD-0001',
}) {
  return <String, dynamic>{
    'membership_id': membershipId,
    'company_id': companyId,
    'company_name': 'Test Co',
    'card_uid': cardUid,
    'status': 'ACTIVE',
    'qr_payload': qrPayload,
    'points_balance': 120,
    'branding': <String, dynamic>{},
  };
}
