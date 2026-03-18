import '../../data/services/client_cards_service.dart';

class GetClientRewardsUseCase {
  GetClientRewardsUseCase(this._service);

  final ClientCardsService _service;

  Future<RewardsResult> call({required String membershipId}) {
    return _service.getRewardsForMembership(membershipId: membershipId);
  }
}
