import '../../core/api/api_client.dart';

class MagicLinkAuthService {
  MagicLinkAuthService(this._apiClient);

  final ApiClient _apiClient;

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
    final defaultMembershipId =
        payload['default_membership_id']?.toString().trim();

    if (accessToken.isEmpty) {
      throw ApiClientException(
        message: 'Session token missing in response.',
        body: payload,
      );
    }

    return MagicLinkSession(
      accessToken: accessToken,
      tokenType: tokenType.isEmpty ? 'Bearer' : tokenType,
      defaultMembershipId:
          defaultMembershipId != null && defaultMembershipId.isNotEmpty
              ? defaultMembershipId
              : null,
    );
  }
}

class MagicLinkSession {
  const MagicLinkSession({
    required this.accessToken,
    required this.tokenType,
    required this.defaultMembershipId,
  });

  final String accessToken;
  final String tokenType;
  final String? defaultMembershipId;
}
