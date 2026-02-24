import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../integrations/deep_links/deep_link_service.dart';
import '../../../client_cards/application/use_cases/get_my_cards_use_case.dart';
import '../../../client_cards/domain/models/client_card.dart';
import '../../application/use_cases/activate_session_from_magic_link_use_case.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required ActivateSessionFromMagicLinkUseCase
        activateSessionFromMagicLinkUseCase,
    required GetMyCardsUseCase getMyCardsUseCase,
    required DeepLinkService deepLinkService,
  })  : _activateSessionFromMagicLinkUseCase =
            activateSessionFromMagicLinkUseCase,
        _getMyCardsUseCase = getMyCardsUseCase,
        _deepLinkService = deepLinkService;

  final ActivateSessionFromMagicLinkUseCase
      _activateSessionFromMagicLinkUseCase;
  final GetMyCardsUseCase _getMyCardsUseCase;
  final DeepLinkService _deepLinkService;

  StreamSubscription<Uri>? _deepLinkSubscription;

  bool _initialized = false;
  bool _loading = false;
  String? _errorMessage;
  String? _infoMessage;
  String? _accessToken;
  String? _lastToken;
  Uri? _lastUri;
  List<ClientCard> _cards = const <ClientCard>[];

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  String? get accessToken => _accessToken;
  String? get lastToken => _lastToken;
  Uri? get lastUri => _lastUri;
  List<ClientCard> get cards => _cards;
  bool get hasActiveSession =>
      _accessToken != null && _accessToken!.trim().isNotEmpty;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _deepLinkSubscription = _deepLinkService.uriStream.listen(
      (uri) async {
        await consumeFromUri(uri);
      },
      onError: (Object error) {
        _setError('No se pudo leer deep link: $error');
      },
    );

    try {
      final initialUri = await _deepLinkService.getInitialUri();
      if (initialUri != null) {
        await consumeFromUri(initialUri);
      }
    } catch (error) {
      _setError('No se pudo procesar el link inicial: $error');
    }
  }

  Future<void> consumeFromInput(String input) async {
    final token = _extractToken(input);
    if (token == null) {
      _setError('Pega un token o link valido con parametro token.');
      return;
    }

    await _consumeToken(token);
  }

  Future<void> consumeFromUri(Uri uri) async {
    _lastUri = uri;
    final token = _extractToken(uri.toString());
    if (token == null) {
      _setError('Se recibio un link sin token valido.');
      return;
    }

    await _consumeToken(token);
  }

  Future<void> refreshCards() async {
    if (!hasActiveSession) {
      _setError('No hay sesion activa. Consume un magic-link primero.');
      return;
    }

    _setLoading(true, 'Consultando /client/me/cards ...');
    try {
      _cards = await _getMyCardsUseCase(accessToken: _accessToken!);
      _errorMessage = null;
      _infoMessage = 'Cards actualizadas: ${_cards.length}.';
    } on ApiClientException catch (error) {
      _setError(error.toString());
    } catch (error) {
      _setError('Error inesperado al cargar cards: $error');
    } finally {
      _setLoading(false);
    }
  }

  void clearSession() {
    _accessToken = null;
    _lastToken = null;
    _cards = const <ClientCard>[];
    _errorMessage = null;
    _infoMessage = 'Sesion limpiada.';
    notifyListeners();
  }

  Future<void> _consumeToken(String token) async {
    _lastToken = token;
    _setLoading(true, 'Consumiendo magic-link ...');
    try {
      final result = await _activateSessionFromMagicLinkUseCase(
        token: token,
        deviceName: AppConstants.defaultDeviceName,
      );
      _accessToken = result.accessToken;
      _cards = result.cards;
      _errorMessage = null;
      _infoMessage = 'Sesion activa. Cards cargadas: ${_cards.length}.';
    } on ApiClientException catch (error) {
      _setError(error.toString());
    } catch (error) {
      _setError('Error inesperado al consumir magic-link: $error');
    } finally {
      _setLoading(false);
    }
  }

  String? _extractToken(String value) {
    final input = value.trim();
    if (input.isEmpty) {
      return null;
    }

    Uri? uri;
    try {
      uri = Uri.parse(input);
    } catch (_) {
      uri = null;
    }

    if (uri != null) {
      final queryToken = uri.queryParameters['token'];
      if (queryToken != null && queryToken.trim().isNotEmpty) {
        return queryToken.trim();
      }
    }

    final maybeToken = input.contains(' ') ? '' : input;
    if (maybeToken.isNotEmpty) {
      return maybeToken;
    }

    return null;
  }

  void _setLoading(bool state, [String? info]) {
    _loading = state;
    if (info != null) {
      _infoMessage = info;
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _loading = false;
    _errorMessage = message;
    _infoMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }
}
