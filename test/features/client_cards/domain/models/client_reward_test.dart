import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/features/client_cards/domain/models/client_reward.dart';

void main() {
  group('ClientReward parsing', () {
    test('maps reward payload values to expected types', () {
      final reward = ClientReward.fromJson(<String, dynamic>{
        'id': 'reward-1',
        'company_id': 'company-1',
        'name': 'Cafe gratis',
        'type': 'FIXED_REWARD',
        'points_cost': '80',
        'is_active': 'true',
        'created_at': '2026-02-16T10:20:00Z',
      });

      expect(reward.id, 'reward-1');
      expect(reward.companyId, 'company-1');
      expect(reward.name, 'Cafe gratis');
      expect(reward.type, 'FIXED_REWARD');
      expect(reward.pointsCost, 80);
      expect(reward.isActive, isTrue);
      expect(reward.createdAt?.toUtc().toIso8601String(), '2026-02-16T10:20:00.000Z');
    });
  });
}
