import 'package:flutter/foundation.dart';
import '../../core/config/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/application/use_cases/consume_magic_link_use_case.dart';
import '../../features/auth/data/services/magic_link_auth_service.dart';
import '../../features/client_cards/application/use_cases/get_my_cards_use_case.dart';
import '../../features/client_cards/data/services/client_cards_service.dart';
import '../../features/home/application/use_cases/activate_session_from_magic_link_use_case.dart';
import '../../integrations/deep_links/deep_link_service.dart';

class AppDependencies {
  AppDependencies._({
    required this.apiClient,
    required this.consumeMagicLinkUseCase,
    required this.getMyCardsUseCase,
    required this.activateSessionFromMagicLinkUseCase,
    required this.deepLinkService,
  });

  final ApiClient apiClient;
  final ConsumeMagicLinkUseCase consumeMagicLinkUseCase;
  final GetMyCardsUseCase getMyCardsUseCase;
  final ActivateSessionFromMagicLinkUseCase
      activateSessionFromMagicLinkUseCase;
  final DeepLinkService deepLinkService;

  factory AppDependencies.create() {
    final apiBaseUrl = AppConstants.apiBaseUrl;
    if (apiBaseUrl.isEmpty) {
      throw ArgumentError('API_BASE_URL is not set.');
    }
    if (kReleaseMode && !apiBaseUrl.startsWith('https://')) {
      throw ArgumentError('API_BASE_URL must use HTTPS in release mode.');
    }

    final apiClient = ApiClient(baseUrl: apiBaseUrl);
    final authService = MagicLinkAuthService(apiClient);
    final cardsService = ClientCardsService(apiClient);
    final consumeMagicLinkUseCase = ConsumeMagicLinkUseCase(authService);
    final getMyCardsUseCase = GetMyCardsUseCase(cardsService);

    return AppDependencies._(
      apiClient: apiClient,
      consumeMagicLinkUseCase: consumeMagicLinkUseCase,
      getMyCardsUseCase: getMyCardsUseCase,
      activateSessionFromMagicLinkUseCase: ActivateSessionFromMagicLinkUseCase(
        consumeMagicLinkUseCase: consumeMagicLinkUseCase,
        getMyCardsUseCase: getMyCardsUseCase,
      ),
      deepLinkService: AppLinksDeepLinkService(),
    );
  }

  void dispose() {
    apiClient.dispose();
  }
}
