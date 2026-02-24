import '../../../../core/network/api_client.dart';
import '../../domain/models/client_card.dart';

class ClientCardsService {
  ClientCardsService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ClientCard>> getMyCards({
    required String accessToken,
  }) async {
    final response = await _apiClient.getJson(
      '/client/me/cards',
      bearerToken: accessToken,
    );

    final dynamic payload = response['data'];
    if (payload is! List) {
      throw ApiClientException(
        message: 'Invalid cards payload.',
        body: payload,
      );
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(ClientCard.fromJson)
        .toList(growable: false);
  }
}
