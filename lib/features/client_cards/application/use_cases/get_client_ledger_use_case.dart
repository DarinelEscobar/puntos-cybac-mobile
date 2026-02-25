import '../../data/services/client_cards_service.dart';
import '../../domain/models/ledger_entry.dart';

class GetClientLedgerUseCase {
  GetClientLedgerUseCase(this._service);

  final ClientCardsService _service;

  Future<List<LedgerEntry>> call({
    required String membershipId,
    int limit = 10,
  }) {
    return _service.getLatestLedger(membershipId: membershipId, limit: limit);
  }
}
