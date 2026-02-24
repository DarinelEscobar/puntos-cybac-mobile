import '../../data/services/client_cards_service.dart';

class GetClientLedgerUseCase {
  GetClientLedgerUseCase(this._service);

  final ClientCardsService _service;

  Future<LedgerResult> call({
    required String membershipId,
    required int page,
    required int perPage,
  }) {
    return _service.getLedger(
      membershipId: membershipId,
      page: page,
      perPage: perPage,
    );
  }
}
