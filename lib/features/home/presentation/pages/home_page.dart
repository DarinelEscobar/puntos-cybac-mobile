import 'package:flutter/material.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../../core/config/app_constants.dart';
import '../../../client_cards/domain/models/client_card.dart';
import '../controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.dependencies,
  });

  final AppDependencies dependencies;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final _hexColorRegExp = RegExp(r'^[0-9a-fA-F]{6}$');

  late final HomeController _controller;
  final TextEditingController _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      activateSessionFromMagicLinkUseCase:
          widget.dependencies.activateSessionFromMagicLinkUseCase,
      getMyCardsUseCase: widget.dependencies.getMyCardsUseCase,
      deepLinkService: widget.dependencies.deepLinkService,
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    _linkController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text(AppConstants.appName)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDebugInfo(),
                  const SizedBox(height: 16),
                  _buildMagicLinkInput(),
                  const SizedBox(height: 16),
                  _buildSessionActions(),
                  const SizedBox(height: 16),
                  _buildCardsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebugInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prueba Magic-Link',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'API: ${AppConstants.apiBaseUrl}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Deep-link esperado: ${AppConstants.magicLinkScheme}://${AppConstants.magicLinkHost}?token=...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_controller.lastUri != null) ...[
              const SizedBox(height: 8),
              Text(
                'Ultimo link recibido: ${_controller.lastUri}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_controller.lastToken != null) ...[
              const SizedBox(height: 8),
              Text(
                'Token detectado: ${_maskToken(_controller.lastToken!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_controller.infoMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _controller.infoMessage!,
                style: const TextStyle(color: Colors.green),
              ),
            ],
            if (_controller.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _controller.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMagicLinkInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consumir magic-link',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _linkController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Pega link completo o token',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _controller.isLoading
                    ? null
                    : () async {
                        await _controller.consumeFromInput(_linkController.text);
                      },
                child: Text(
                  _controller.isLoading
                      ? 'Procesando...'
                      : 'Consumir y cargar cards',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _controller.isLoading
                ? null
                : () async {
                    await _controller.refreshCards();
                  },
            child: const Text('Refrescar cards'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: _controller.isLoading
                ? null
                : () {
                    _controller.clearSession();
                  },
            child: const Text('Limpiar sesion'),
          ),
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    if (_controller.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_controller.cards.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _controller.hasActiveSession
                ? 'Sesion activa pero sin cards.'
                : 'Aun no hay sesion de cliente. Consume un magic-link.',
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cards (${_controller.cards.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _controller.cards.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final card = _controller.cards[index];
            return _buildCardItem(card);
          },
        ),
      ],
    );
  }

  Widget _buildCardItem(ClientCard card) {
    final accentColor = _hexToColor(
      card.branding.colorAccent,
      const Color(0xFF0EA5E9),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.companyName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Puntos: ${card.pointsBalance}', accentColor),
                _chip('Card: ${card.cardUid}', Colors.black87),
                _chip('Status: ${card.status}', Colors.black54),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'membership_id: ${card.membershipId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'company_id: ${card.companyId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'qr_payload: ${card.qrPayload}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _hexToColor(String? hex, Color fallback) {
    if (hex == null) {
      return fallback;
    }

    final normalized = hex.trim().replaceFirst('#', '');
    if (!_hexColorRegExp.hasMatch(normalized)) {
      return fallback;
    }

    return Color(int.parse('FF$normalized', radix: 16));
  }

  String _maskToken(String token) {
    if (token.length <= 12) {
      return token;
    }
    return '${token.substring(0, 8)}...${token.substring(token.length - 4)}';
  }
}
