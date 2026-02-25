import '../../../../core/network/api_client.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/models/client_card.dart';
import '../../domain/models/client_reward.dart';
import '../../domain/models/ledger_entry.dart';

class ClientCardsService {
  ClientCardsService(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  Future<List<ClientCard>> getMyCards() async {
    final token = await _tokenStorage.getToken();
    final response = await _apiClient.getJson(
      '/client/me/cards',
      bearerToken: token,
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

  Future<List<LedgerEntry>> getLatestLedger({
    required String membershipId,
    int limit = 10,
  }) async {
    final token = await _tokenStorage.getToken();
    final query = Uri(
      queryParameters: <String, String>{
        'membership_id': membershipId,
        'limit': '$limit',
      },
    ).query;

    final response = await _apiClient.getJson(
      '/client/me/ledger/latest?$query',
      bearerToken: token,
    );

    final dynamic payload = response['data'];
    if (payload is! Map<String, dynamic>) {
      throw ApiClientException(
        message: 'Invalid ledger payload.',
        body: payload,
      );
    }

    final entriesPayload = payload['entries'];
    if (entriesPayload is! List) {
      throw ApiClientException(
        message: 'Invalid ledger payload.',
        body: payload,
      );
    }

    return entriesPayload
        .whereType<Map>()
        .map((map) => map.map((key, value) => MapEntry(key.toString(), value)))
        .map((map) => LedgerEntry.fromJson(map))
        .toList(growable: false);
  }

  Future<RewardsResult> getRewardsForMembership({
    required String membershipId,
  }) async {
    final token = await _tokenStorage.getToken();
    final query = Uri(
      queryParameters: <String, String>{'membership_id': membershipId},
    ).query;

    final response = await _apiClient.getJson(
      '/client/me/rewards?$query',
      bearerToken: token,
    );

    final dynamic payload = response['data'];
    if (payload is! Map<String, dynamic>) {
      throw ApiClientException(
        message: 'Invalid rewards payload.',
        body: payload,
      );
    }

    final rewardsPayload = payload['rewards'];
    if (rewardsPayload is! List) {
      throw ApiClientException(
        message: 'Invalid rewards payload.',
        body: payload,
      );
    }

    final rewards = rewardsPayload
        .whereType<Map>()
        .map((map) => map.map((key, value) => MapEntry(key.toString(), value)))
        .map((map) => ClientReward.fromJson(map))
        .toList(growable: false);

    return RewardsResult(
      membershipId: (payload['membership_id'] ?? '').toString(),
      rewards: rewards,
    );
  }
}

class RewardsResult {
  const RewardsResult({required this.membershipId, required this.rewards});

  final String membershipId;
  final List<ClientReward> rewards;
}
