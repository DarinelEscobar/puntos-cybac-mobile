import '../../../../core/network/api_client.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/models/client_profile.dart';
import '../../domain/models/membership.dart';

class ClientProfileResult {
  const ClientProfileResult({
    required this.profile,
    required this.memberships,
  });

  final ClientProfile profile;
  final List<Membership> memberships;
}

class ClientRepository {
  ClientRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  Future<ClientProfileResult> getProfile() async {
    final token = await _tokenStorage.getToken();
    final response = await _apiClient.getJson(
      '/client/me/profile',
      bearerToken: token,
    );

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiClientException(
        message: 'Invalid profile response',
        body: response,
      );
    }

    final clientIdentity = data['client_identity'];
    if (clientIdentity is! Map<String, dynamic>) {
      throw ApiClientException(
        message: 'Invalid client identity',
        body: data,
      );
    }

    final profile = ClientProfile.fromJson(clientIdentity);

    final membershipsData = data['memberships'];
    final List<Membership> memberships = [];
    if (membershipsData is List) {
      for (final item in membershipsData) {
        if (item is Map<String, dynamic>) {
          final membershipData = item['membership'];
           if (membershipData is Map<String, dynamic>) {
              memberships.add(Membership.fromJson(membershipData));
           }
        }
      }
    }

    return ClientProfileResult(
      profile: profile,
      memberships: memberships,
    );
  }
}
