import '../../../../client_cards/domain/models/client_card.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../profile/domain/models/client_profile.dart';
import '../../domain/models/magic_link_session.dart';

class MagicLinkAuthService {
  MagicLinkAuthService(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  Future<MagicLinkSession> consumeMagicLink({
    required String token,
    required String deviceName,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/client/magic-links/consume',
      body: <String, dynamic>{
        'token': token,
        'device_name': deviceName,
      },
    );

    final dynamic payload = response['data'];
    if (payload is! Map<String, dynamic>) {
      throw ApiClientException(
        message: 'Invalid session payload.',
        body: payload,
      );
    }

    final accessToken = payload['access_token']?.toString().trim() ?? '';
    final tokenType = payload['token_type']?.toString().trim() ?? 'Bearer';

    if (accessToken.isEmpty) {
      throw ApiClientException(
        message: 'Session token missing in response.',
        body: payload,
      );
    }

    // Parse Profile
    final profileData = payload['profile'];
    if (profileData is! Map<String, dynamic>) {
       throw ApiClientException(
        message: 'Profile missing in response.',
        body: payload,
      );
    }

    final clientIdentity = profileData['client_identity'];
    if (clientIdentity is! Map<String, dynamic>) {
       throw ApiClientException(
        message: 'Client identity missing in response.',
        body: payload,
      );
    }

    final profile = ClientProfile.fromJson(clientIdentity);

    // Parse Cards
    final cardsData = payload['cards'];
    final List<ClientCard> cards = [];
    if (cardsData is List) {
      for (final item in cardsData) {
        if (item is Map<String, dynamic>) {
          cards.add(ClientCard.fromJson(item));
        }
      }
    }

    // Save token
    await _tokenStorage.saveToken(accessToken);

    return MagicLinkSession(
      accessToken: accessToken,
      tokenType: tokenType.isEmpty ? 'Bearer' : tokenType,
      profile: profile,
      cards: cards,
    );
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }
}
