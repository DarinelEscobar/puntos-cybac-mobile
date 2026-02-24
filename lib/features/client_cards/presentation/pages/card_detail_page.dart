import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/ui/widgets/digital_card.dart';
import '../../../../core/ui/widgets/error_view.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../application/use_cases/get_client_ledger_use_case.dart';
import '../../data/services/client_cards_service.dart';
import '../../domain/models/client_card.dart';
import '../../domain/models/ledger_entry.dart';

class CardDetailPage extends StatefulWidget {
  const CardDetailPage({
    super.key,
    required this.card,
    required this.dependencies,
  });

  final ClientCard card;
  final AppDependencies dependencies;

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _isFront = true;

  // Ledger state
  final List<LedgerEntry> _ledgerEntries = [];
  bool _isLoadingLedger = false;
  String? _ledgerError;
  int _page = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  GetClientLedgerUseCase get _getLedger =>
      widget.dependencies.getClientLedgerUseCase;

  @override
  void initState() {
    super.initState();
    // Flip animation setup
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Load ledger
    _loadLedger();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    _isFront = !_isFront;
  }

  Future<void> _loadLedger({bool refresh = false}) async {
    if (_isLoadingLedger || (!_hasMore && !refresh)) return;

    if (refresh) {
      _page = 1;
      _hasMore = true;
      _ledgerEntries.clear();
      _ledgerError = null;
    }

    setState(() {
      _isLoadingLedger = true;
    });

    try {
      final result = await _getLedger(
        membershipId: widget.card.membershipId,
        page: _page,
        perPage: 25,
      );

      if (mounted) {
        setState(() {
          _ledgerEntries.addAll(result.entries);
          _hasMore = result.entries.length >= 25;
          if (_hasMore) _page++;
          _isLoadingLedger = false;
        });
      }
    } on ApiClientException catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLedger = false;
          if (refresh) {
             if (e.errorCode == 'MEMBERSHIP_NOT_OWNED') {
               _ledgerError = 'No tienes acceso a esta membresía.';
             } else {
               _ledgerError = 'Error al cargar movimientos: ${e.message}';
             }
          } else {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLedger = false;
          if (refresh) {
            _ledgerError = 'Error inesperado.';
          }
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadLedger();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.card.companyName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadLedger(refresh: true),
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Flip Card Container
                    Center(
                      child: Hero(
                        tag: 'card_${widget.card.cardUid}',
                        child: AnimatedBuilder(
                          animation: _flipController,
                          builder: (context, child) {
                            final angle = _flipController.value * pi;
                            final isBack = angle >= pi / 2;
                            final transform = Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle);

                            if (isBack) {
                                // Mirror back side so it looks correct
                                transform.rotateY(pi);
                            }

                            return Transform(
                              transform: transform,
                              alignment: Alignment.center,
                              child: isBack
                                  ? DigitalCard(card: widget.card, isBack: true)
                                  : DigitalCard(
                                      card: widget.card,
                                      isBack: false,
                                      onTap: null,
                                    ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Flip Button
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: _flipCard,
                        icon: const Icon(Icons.flip_camera_android),
                        label: const Text('Voltear tarjeta'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Ledger Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Movimientos',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Ledger List or States
                    if (_ledgerError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: ErrorView(
                          message: _ledgerError!,
                          onRetry: () => _loadLedger(refresh: true),
                        ),
                      )
                    else if (_ledgerEntries.isEmpty && !_isLoadingLedger)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'Aún no tienes movimientos en esta tarjeta.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _ledgerEntries.length + (_isLoadingLedger ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (index == _ledgerEntries.length) {
                             return const Padding(
                               padding: EdgeInsets.symmetric(vertical: 24),
                               child: Loader(),
                             );
                          }
                          return _buildLedgerItem(_ledgerEntries[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerItem(LedgerEntry entry) {
    final isEarn = entry.type == 'EARN';
    final isRedeem = entry.type == 'REDEEM';

    final color = isEarn ? Colors.green : (isRedeem ? Colors.orange : Colors.blue);
    final icon = isEarn ? Icons.add_circle_outline : (isRedeem ? Icons.remove_circle_outline : Icons.info_outline);
    final sign = isEarn ? '+' : (isRedeem ? '-' : '');

    final dateStr = entry.createdAt != null
       ? DateFormat('dd MMM, hh:mm a').format(entry.createdAt!.toLocal())
       : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(
               color: color.withOpacity(0.1),
               shape: BoxShape.circle,
             ),
             child: Icon(icon, color: color, size: 24),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   entry.note ?? (isEarn ? 'Compra' : 'Canje'),
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                 ),
                 if (dateStr.isNotEmpty) ...[
                   const SizedBox(height: 4),
                   Text(
                     dateStr,
                     style: const TextStyle(color: Colors.grey, fontSize: 12),
                   ),
                 ],
               ],
             ),
           ),
           Text(
             '$sign${entry.pointsDelta} pts',
             style: TextStyle(
               color: color,
               fontWeight: FontWeight.bold,
               fontSize: 16,
             ),
           ),
        ],
      ),
    );
  }
}
