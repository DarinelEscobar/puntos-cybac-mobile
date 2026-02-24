import '../../data/services/client_cards_service.dart';
import '../../domain/models/client_card.dart';

class GetMyCardsUseCase {
  GetMyCardsUseCase(this._cardsService);

  final ClientCardsService _cardsService;

  Future<List<ClientCard>> call({
    required String accessToken,
  }) {
    return _cardsService.getMyCards(accessToken: accessToken);
  }
}
