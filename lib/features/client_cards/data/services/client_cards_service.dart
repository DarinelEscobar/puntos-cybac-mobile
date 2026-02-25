import '../../../../core/network/api_client.dart';
import '../../domain/models/client_card.dart';

class ClientCardsService {
  ClientCardsService(this._apiClient);

  final ApiClient _apiClient;

  String? _cachedToken;
  List<ClientCard>? _cachedCards;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  Future<List<ClientCard>> getMyCards({
    required String accessToken,
    bool forceRefresh = false,
  }) async {
    final isSameToken = accessToken == _cachedToken;

    if (!forceRefresh &&
        isSameToken &&
        _cachedCards != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedCards!;
    }

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

    _cachedCards = payload
        .whereType<Map<String, dynamic>>()
        .map(ClientCard.fromJson)
        .toList(growable: false);
    _cachedToken = accessToken;
    _lastFetchTime = DateTime.now();

    return _cachedCards!;
  }
}
