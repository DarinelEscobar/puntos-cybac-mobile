import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/core/network/api_client.dart';
import 'package:puntos_cybac_mobile/features/client_cards/data/services/client_cards_service.dart';

class MockApiClient extends ApiClient {
  MockApiClient() : super(baseUrl: 'https://api.example.com');

  int getJsonCalls = 0;
  Duration delay = const Duration(milliseconds: 100);

  @override
  Future<Map<String, dynamic>> getJson(String path, {String? bearerToken}) async {
    getJsonCalls++;
    await Future.delayed(delay);
    return {
      'data': [
        {
          'membership_id': '1',
          'company_id': '1',
          'company_name': 'Test Company',
          'card_uid': 'UID123',
          'status': 'active',
          'qr_payload': 'QR123',
          'points_balance': 100,
          'branding': {
            'logo_url': 'https://example.com/logo.png',
            'color_primary': '#FF0000',
          }
        }
      ]
    };
  }
}

void main() {
  group('ClientCardsService Benchmark', () {
    late MockApiClient mockApiClient;
    late ClientCardsService service;

    setUp(() {
      mockApiClient = MockApiClient();
      service = ClientCardsService(mockApiClient);
    });

    test('Measure getMyCards performance with cache', () async {
      final stopwatch = Stopwatch()..start();

      // First call (hits API)
      await service.getMyCards(accessToken: 'token123');
      // Second call (hits cache)
      await service.getMyCards(accessToken: 'token123');
      // Third call (hits cache)
      await service.getMyCards(accessToken: 'token123');

      stopwatch.stop();

      print('Total time for 3 calls with caching: ${stopwatch.elapsedMilliseconds}ms');
      print('Total API calls: ${mockApiClient.getJsonCalls}');

      // Only 1 call should have been made to the API
      expect(mockApiClient.getJsonCalls, 1);
      // Time should be around 100ms (not 300ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('getMyCards forceRefresh bypasses cache', () async {
      // First call
      await service.getMyCards(accessToken: 'token123');
      expect(mockApiClient.getJsonCalls, 1);

      // Second call with forceRefresh
      await service.getMyCards(accessToken: 'token123', forceRefresh: true);
      expect(mockApiClient.getJsonCalls, 2);
    });

    test('getMyCards different token bypasses cache', () async {
      // First call
      await service.getMyCards(accessToken: 'token123');
      expect(mockApiClient.getJsonCalls, 1);

      // Second call with different token
      await service.getMyCards(accessToken: 'other_token');
      expect(mockApiClient.getJsonCalls, 2);
    });
  });
}
