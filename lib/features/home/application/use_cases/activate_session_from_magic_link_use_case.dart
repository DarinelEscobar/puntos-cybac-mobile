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

    // Cards are now fetched implicitly using the stored token or from the session payload if available
    // For now, we fetch them again or use the ones from session if ConsumeMagicLinkUseCase returns them (it does in our new model)

    // The session object now contains cards!
    // So we don't strictly need to call getMyCardsUseCase if the session already has them.
    // However, to keep it consistent with the original logic which might want fresh cards or separate concerns:
    // The previous implementation called _getMyCardsUseCase(accessToken).
    // Our new GetMyCardsUseCase does not take arguments.

    // Optimally, we use the cards from the session response directly to save a call.
    if (session.cards.isNotEmpty) {
      return ActivatedSession(
        accessToken: session.accessToken,
        cards: session.cards,
      );
    }

    final cards = await _getMyCardsUseCase();

    return ActivatedSession(
      accessToken: session.accessToken,
      cards: cards,
    );
  }
}
