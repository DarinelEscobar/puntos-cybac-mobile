import '../../data/services/client_cards_service.dart';
import '../../domain/models/client_card.dart';

class GetMyCardsUseCase {
  GetMyCardsUseCase(this._cardsService);

  final ClientCardsService _cardsService;

  Future<List<ClientCard>> call() {
    return _cardsService.getMyCards();
  }
}
