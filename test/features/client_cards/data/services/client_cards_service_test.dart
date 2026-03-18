import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/core/network/api_client.dart';
import 'package:puntos_cybac_mobile/features/client_cards/data/services/client_cards_service.dart';

class MockApiClient implements ApiClient {
  @override
  String get baseUrl => 'https://api.example.com';

  Map<String, dynamic>? getJsonResponse;
  Object? getJsonError;
  String? lastPath;
  String? lastBearerToken;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    String? bearerToken,
  }) async {
    lastPath = path;
    lastBearerToken = bearerToken;
    if (getJsonError != null) {
      throw getJsonError!;
    }
    return getJsonResponse ?? {};
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    String? bearerToken,
  }) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}
}

void main() {
  late ClientCardsService service;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    service = ClientCardsService(mockApiClient);
  });

  group('ClientCardsService.getMyCards', () {
    const accessToken = 'test_token';

    test('should return a list of ClientCard when API call is successful', () async {
      // Arrange
      mockApiClient.getJsonResponse = {
        'data': [
          {
            'membership_id': 'm1',
            'company_id': 'c1',
            'company_name': 'Company 1',
            'card_uid': 'uid1',
            'status': 'active',
            'qr_payload': 'qr1',
            'points_balance': 100,
            'branding': {
              'logo_url': 'logo1',
              'color_primary': '#000000',
            },
          },
          {
            'membership_id': 'm2',
            'company_id': 'c2',
            'company_name': 'Company 2',
            'card_uid': 'uid2',
            'status': 'active',
            'qr_payload': 'qr2',
            'points_balance': 200,
            'branding': {},
          },
        ],
      };

      // Act
      final result = await service.getMyCards(accessToken: accessToken);

      // Assert
      expect(mockApiClient.lastPath, '/client/me/cards');
      expect(mockApiClient.lastBearerToken, accessToken);
      expect(result.length, 2);
      expect(result[0].membershipId, 'm1');
      expect(result[0].pointsBalance, 100);
      expect(result[1].membershipId, 'm2');
      expect(result[1].pointsBalance, 200);
    });

    test('should throw ApiClientException when payload data is not a list', () async {
      // Arrange
      mockApiClient.getJsonResponse = {
        'data': 'not a list',
      };

      // Act & Assert
      expect(
        () => service.getMyCards(accessToken: accessToken),
        throwsA(isA<ApiClientException>()),
      );
    });

    test('should filter out invalid map entries in payload list', () async {
      // Arrange
      mockApiClient.getJsonResponse = {
        'data': [
          {
            'membership_id': 'm1',
            'company_id': 'c1',
            'company_name': 'Company 1',
            'card_uid': 'uid1',
            'status': 'active',
            'qr_payload': 'qr1',
            'points_balance': 100,
            'branding': {},
          },
          'not a map',
          null,
        ],
      };

      // Act
      final result = await service.getMyCards(accessToken: accessToken);

      // Assert
      expect(result.length, 1);
      expect(result[0].membershipId, 'm1');
    });

    test('should return empty list when data is empty list', () async {
      // Arrange
      mockApiClient.getJsonResponse = {
        'data': [],
      };

      // Act
      final result = await service.getMyCards(accessToken: accessToken);

      // Assert
      expect(result, isEmpty);
    });
  });
}
