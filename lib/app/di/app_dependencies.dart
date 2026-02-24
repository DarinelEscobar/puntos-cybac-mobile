import 'package:flutter/foundation.dart';
import '../../core/config/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/services/token_storage_service.dart';
import '../../features/auth/application/use_cases/consume_magic_link_use_case.dart';
import '../../features/auth/data/services/magic_link_auth_service.dart';
import '../../features/client_cards/application/use_cases/get_client_ledger_use_case.dart';
import '../../features/client_cards/application/use_cases/get_my_cards_use_case.dart';
import '../../features/client_cards/data/services/client_cards_service.dart';
import '../../features/home/application/use_cases/activate_session_from_magic_link_use_case.dart';
import '../../features/profile/application/use_cases/get_profile_use_case.dart';
import '../../features/profile/data/repositories/client_repository.dart';
import '../../integrations/deep_links/deep_link_service.dart';

class AppDependencies {
  AppDependencies._({
    required this.apiClient,
    required this.tokenStorageService,
    required this.consumeMagicLinkUseCase,
    required this.getMyCardsUseCase,
    required this.getProfileUseCase,
    required this.getClientLedgerUseCase,
    required this.activateSessionFromMagicLinkUseCase,
    required this.deepLinkService,
  });

  final ApiClient apiClient;
  final TokenStorageService tokenStorageService;
  final ConsumeMagicLinkUseCase consumeMagicLinkUseCase;
  final GetMyCardsUseCase getMyCardsUseCase;
  final GetProfileUseCase getProfileUseCase;
  final GetClientLedgerUseCase getClientLedgerUseCase;
  final ActivateSessionFromMagicLinkUseCase activateSessionFromMagicLinkUseCase;
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
    final tokenStorage = TokenStorageService();

    final authService = MagicLinkAuthService(apiClient, tokenStorage);
    final cardsService = ClientCardsService(apiClient, tokenStorage);
    final clientRepo = ClientRepository(apiClient, tokenStorage);
    final consumeMagicLinkUseCase = ConsumeMagicLinkUseCase(authService);
    final getMyCardsUseCase = GetMyCardsUseCase(cardsService);
    final getProfileUseCase = GetProfileUseCase(clientRepo);
    final getClientLedgerUseCase = GetClientLedgerUseCase(cardsService);

    return AppDependencies._(
      apiClient: apiClient,
      tokenStorageService: tokenStorage,
      consumeMagicLinkUseCase: consumeMagicLinkUseCase,
      getMyCardsUseCase: getMyCardsUseCase,
      getProfileUseCase: getProfileUseCase,
      getClientLedgerUseCase: getClientLedgerUseCase,
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
