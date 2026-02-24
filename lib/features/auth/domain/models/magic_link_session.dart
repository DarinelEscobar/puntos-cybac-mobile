import '../../../../client_cards/domain/models/client_card.dart';
import '../../../profile/domain/models/client_profile.dart';

class MagicLinkSession {
  const MagicLinkSession({
    required this.accessToken,
    required this.tokenType,
    required this.profile,
    required this.cards,
  });

  final String accessToken;
  final String tokenType;
  final ClientProfile profile;
  final List<ClientCard> cards;
}
