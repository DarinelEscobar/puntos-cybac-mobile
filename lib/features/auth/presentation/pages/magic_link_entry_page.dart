import 'package:flutter/material.dart';
import '../../../../app/di/app_dependencies.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../application/use_cases/consume_magic_link_use_case.dart';
import '../../../home/presentation/pages/session_bootstrap_page.dart';

class MagicLinkEntryPage extends StatefulWidget {
  const MagicLinkEntryPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<MagicLinkEntryPage> createState() => _MagicLinkEntryPageState();
}

class _MagicLinkEntryPageState extends State<MagicLinkEntryPage> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  ConsumeMagicLinkUseCase get _consumeMagicLink =>
      widget.dependencies.consumeMagicLinkUseCase;

  Future<void> _submit() async {
    final token = _extractToken(_tokenController.text);
    if (token == null) {
      setState(() {
        _error = 'Pega un token valido o un link con ?token=...';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _consumeMagicLink(
        token: token,
        deviceName: AppConstants.defaultDeviceName,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                SessionBootstrapPage(dependencies: widget.dependencies),
          ),
        );
      }
    } on ApiClientException catch (e) {
      if (mounted) {
        setState(() {
          _error = _mapApiErrorToMessage(e);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Ocurrió un error inesperado. Intenta nuevamente.';
          _isLoading = false;
        });
      }
    }
  }

  String _mapApiErrorToMessage(ApiClientException error) {
    final code = error.errorCode?.trim();
    switch (code) {
      case 'MAGIC_LINK_INVALID_FORMAT':
        return 'El enlace no es válido.';
      case 'MAGIC_LINK_ALREADY_CONSUMED':
        return 'Este enlace ya fue usado.';
      case 'MAGIC_LINK_EXPIRED':
        return 'Este enlace expiró. Solicita uno nuevo.';
      default:
        final message = error.message.trim();
        final lowerMessage = message.toLowerCase();

        if (lowerMessage.contains('no host specified') ||
            lowerMessage.contains('failed host lookup') ||
            lowerMessage.contains('connection refused')) {
          return 'No se pudo conectar al API. Revisa API_BASE_URL y que el backend esté accesible.';
        }

        if (message.isNotEmpty) {
          if (error.statusCode != null) {
            return '$message (HTTP ${error.statusCode}).';
          }
          return message;
        }

        return 'No se pudo iniciar sesión. Intenta nuevamente.';
    }
  }

  String? _extractToken(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final uri = Uri.parse(trimmed);
      final queryToken = uri.queryParameters['token'];
      if (queryToken != null && queryToken.trim().isNotEmpty) {
        return queryToken.trim();
      }
    } catch (_) {
      // Ignore parse errors and continue with token heuristics.
    }

    final normalized = trimmed.replaceAll(RegExp(r'\s+'), '');
    final match = RegExp(r'[A-Za-z0-9_-]{24,255}').firstMatch(normalized);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.loyalty,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),

              const SizedBox(height: 32),

              // Illustration
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Bienvenido',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Pega el enlace completo o el token recibido por correo para acceder a tus tarjetas.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'API: ${AppConstants.apiBaseUrl}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Form
              TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText: 'Token de acceso',
                  hintText:
                      'Ej. cybacpuntos://magic-link?token=... o solo token',
                  prefixIcon: const Icon(Icons.key),
                  errorText: _error,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),

              const SizedBox(height: 24),

              if (_isLoading)
                const Loader()
              else
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continuar', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.help_outline, size: 18),
                label: const Text('¿Necesitas ayuda?'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
