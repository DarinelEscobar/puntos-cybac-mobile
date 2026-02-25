import 'package:flutter/material.dart';
import '../../../../app/di/app_dependencies.dart';
import '../../../../core/ui/widgets/digital_card.dart';
import '../../../../core/ui/widgets/error_view.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../domain/models/client_card.dart';
import 'card_detail_page.dart';

class HomeCardsPage extends StatefulWidget {
  const HomeCardsPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<HomeCardsPage> createState() => _HomeCardsPageState();
}

class _HomeCardsPageState extends State<HomeCardsPage> {
  static const String _cardCreationHelpMessage =
      'Para crear una tarjeta de esta compania, pide apoyo al cajero o al personal de la tienda. '
      'Solo comparte tu numero o correo con el staff.';

  late Future<List<ClientCard>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    setState(() {
      _cardsFuture = widget.dependencies.getMyCardsUseCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.wallet, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mis Tarjetas',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            FutureBuilder<List<ClientCard>>(
                              future: _cardsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    '${snapshot.data!.length} tarjetas activas',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => _showCardCreationInfoModal(context),
                    tooltip: 'Como obtener una tarjeta',
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: FutureBuilder<List<ClientCard>>(
                future: _cardsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }

                  if (snapshot.hasError) {
                    return ErrorView(
                      message: 'Error al cargar tarjetas: ${snapshot.error}',
                      onRetry: _loadCards,
                    );
                  }

                  final cards = snapshot.data ?? [];

                  if (cards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card_off, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Aún no tienes tarjetas activas',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: _loadCards,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Actualizar'),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _showCardCreationInfoModal(context),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Como obtengo una tarjeta?'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Consulta con staff en tienda para activarla.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadCards();
                      await _cardsFuture;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: cards.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return Hero(
                          tag: 'card_${card.cardUid}',
                          child: DigitalCard(
                            card: card,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CardDetailPage(
                                    card: card,
                                    dependencies: widget.dependencies,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCardCreationInfoModal(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.info_outline, color: Colors.amber[800]),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Alta de tarjeta',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _cardCreationHelpMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Entendido'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
