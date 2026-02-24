import '../../../auth/application/use_cases/consume_magic_link_use_case.dart';
import '../../../client_cards/application/use_cases/get_my_cards_use_case.dart';
import '../models/activated_session.dart';

class ActivateSessionFromMagicLinkUseCase {
  ActivateSessionFromMagicLinkUseCase({
    required ConsumeMagicLinkUseCase consumeMagicLinkUseCase,
    required GetMyCardsUseCase getMyCardsUseCase,
  })  : _consumeMagicLinkUseCase = consumeMagicLinkUseCase,
        _getMyCardsUseCase = getMyCardsUseCase;

  final ConsumeMagicLinkUseCase _consumeMagicLinkUseCase;
  final GetMyCardsUseCase _getMyCardsUseCase;

  Future<ActivatedSession> call({
    required String token,
    required String deviceName,
  }) async {
    final session = await _consumeMagicLinkUseCase(
      token: token,
      deviceName: deviceName,
    );

    final cards = await _getMyCardsUseCase(accessToken: session.accessToken);

    return ActivatedSession(
      accessToken: session.accessToken,
      cards: cards,
    );
  }
}
