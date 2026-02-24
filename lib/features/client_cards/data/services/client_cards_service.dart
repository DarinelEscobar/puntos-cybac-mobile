import '../../../../core/network/api_client.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/models/client_card.dart';
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
        .whereType<Map>()
        .map((map) => map.map((key, value) => MapEntry(key.toString(), value)))
        .map((map) => ClientCard.fromJson(map))
        .toList(growable: false);
  }

  Future<LedgerResult> getLedger({
    required String membershipId,
    required int page,
    required int perPage,
  }) async {
    final token = await _tokenStorage.getToken();
    final response = await _apiClient.getJson(
      '/client/me/ledger?membership_id=$membershipId&page=$page&per_page=$perPage',
      bearerToken: token,
    );

    final dynamic data = response['data'];
    if (data is! List) {
      throw ApiClientException(
        message: 'Invalid ledger payload.',
        body: data,
      );
    }

    final entries = data
        .whereType<Map>()
        .map((map) => map.map((key, value) => MapEntry(key.toString(), value)))
        .map((map) => LedgerEntry.fromJson(map))
        .toList(growable: false);

    final meta = response['meta'];
    PaginationMeta? pagination;
    if (meta is Map<String, dynamic>) {
      final p = meta['pagination'];
      if (p is Map<String, dynamic>) {
        pagination = PaginationMeta.fromJson(p);
      }
    }

    return LedgerResult(entries: entries, pagination: pagination);
  }
}

class LedgerResult {
  const LedgerResult({
    required this.entries,
    this.pagination,
  });

  final List<LedgerEntry> entries;
  final PaginationMeta? pagination;
}

class PaginationMeta {
  const PaginationMeta({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: _asInt(json['total']),
      count: _asInt(json['count']),
      perPage: _asInt(json['per_page']),
      currentPage: _asInt(json['current_page']),
      totalPages: _asInt(json['total_pages']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
