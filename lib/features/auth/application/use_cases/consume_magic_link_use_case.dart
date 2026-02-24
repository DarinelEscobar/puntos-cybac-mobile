import '../../data/services/magic_link_auth_service.dart';
import '../../domain/models/magic_link_session.dart';

class ConsumeMagicLinkUseCase {
  ConsumeMagicLinkUseCase(this._authService);

  final MagicLinkAuthService _authService;

  Future<MagicLinkSession> call({
    required String token,
    required String deviceName,
  }) {
    return _authService.consumeMagicLink(
      token: token,
      deviceName: deviceName,
    );
  }
}
