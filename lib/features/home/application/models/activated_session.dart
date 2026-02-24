import '../../../client_cards/domain/models/client_card.dart';

class ActivatedSession {
  const ActivatedSession({
    required this.accessToken,
    required this.cards,
  });

  final String accessToken;
  final List<ClientCard> cards;
}
