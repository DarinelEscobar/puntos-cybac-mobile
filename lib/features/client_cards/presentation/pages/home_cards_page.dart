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
                  Row(
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
                  IconButton(
                    onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agregar tarjeta: Próximamente")));
                    },
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey[200]!),
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
                      itemCount: cards.length + 1, // +1 for "Add new card" button at bottom
                      separatorBuilder: (context, index) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        if (index == cards.length) {
                           return _buildAddCardButton(context);
                        }

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

  Widget _buildAddCardButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agregar tarjeta: Próximamente")));
      },
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_card, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Agregar nueva tarjeta',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
