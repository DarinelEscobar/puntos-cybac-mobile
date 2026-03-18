import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/ui/widgets/digital_card.dart';
import '../../../../core/ui/widgets/error_view.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../application/use_cases/get_client_ledger_use_case.dart';
import '../../application/use_cases/get_client_rewards_use_case.dart';
import '../../domain/models/client_card.dart';
import '../../domain/models/client_reward.dart';
import '../../domain/models/ledger_entry.dart';

enum _CardDetailSection { ledger, rewards }

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
  _CardDetailSection _section = _CardDetailSection.ledger;

  final List<LedgerEntry> _ledgerEntries = [];
  bool _isLoadingLedger = false;
  String? _ledgerError;

  final List<ClientReward> _rewards = [];
  bool _isLoadingRewards = false;
  bool _rewardsLoaded = false;
  String? _rewardsError;

  GetClientLedgerUseCase get _getLedger =>
      widget.dependencies.getClientLedgerUseCase;
  GetClientRewardsUseCase get _getRewards =>
      widget.dependencies.getClientRewardsUseCase;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _loadLedger();
    _loadRewards();
  }

  @override
  void dispose() {
    _flipController.dispose();
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
    if (_isLoadingLedger) return;

    if (refresh) {
      _ledgerEntries.clear();
      _ledgerError = null;
    }

    setState(() {
      _isLoadingLedger = true;
    });

    try {
      final latestEntries = await _getLedger(
        membershipId: widget.card.membershipId,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          _ledgerEntries
            ..clear()
            ..addAll(latestEntries);
          _isLoadingLedger = false;
        });
      }
    } on ApiClientException catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLedger = false;
          if (e.errorCode == 'MEMBERSHIP_NOT_OWNED') {
            _ledgerError = 'No tienes acceso a esta membresia.';
          } else {
            _ledgerError = 'Error al cargar ultimos movimientos: ${e.message}';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingLedger = false;
          _ledgerError = 'Error inesperado.';
        });
      }
    }
  }

  Future<void> _loadRewards({bool refresh = false}) async {
    if (_isLoadingRewards) return;

    if (refresh) {
      _rewards.clear();
      _rewardsError = null;
    }

    setState(() {
      _isLoadingRewards = true;
    });

    try {
      final result = await _getRewards(membershipId: widget.card.membershipId);

      if (mounted) {
        setState(() {
          _rewards
            ..clear()
            ..addAll(result.rewards);
          _rewardsLoaded = true;
          _rewardsError = null;
          _isLoadingRewards = false;
        });
      }
    } on ApiClientException catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRewards = false;
          _rewardsLoaded = true;
          if (e.errorCode == 'MEMBERSHIP_NOT_OWNED') {
            _rewardsError = 'No tienes acceso a esta membresia.';
          } else {
            _rewardsError = 'Error al cargar rewards: ${e.message}';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRewards = false;
          _rewardsLoaded = true;
          _rewardsError = 'Error inesperado.';
        });
      }
    }
  }

  Future<void> _refreshCurrentSection() {
    if (_section == _CardDetailSection.ledger) {
      return _loadLedger(refresh: true);
    }

    return _loadRewards(refresh: true);
  }

  void _selectSection(_CardDetailSection section) {
    if (_section == section) return;

    setState(() {
      _section = section;
    });

    if (section == _CardDetailSection.rewards &&
        !_rewardsLoaded &&
        !_isLoadingRewards) {
      _loadRewards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshCurrentSection,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
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
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: _flipCard,
                        icon: const Icon(Icons.flip_camera_android),
                        label: const Text('Voltear tarjeta'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSectionButton(
                            label: 'Ultimos movimientos',
                            icon: Icons.receipt_long,
                            isSelected: _section == _CardDetailSection.ledger,
                            onTap: () =>
                                _selectSection(_CardDetailSection.ledger),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSectionButton(
                            label: 'Rewards',
                            icon: Icons.redeem,
                            isSelected: _section == _CardDetailSection.rewards,
                            onTap: () =>
                                _selectSection(_CardDetailSection.rewards),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_section == _CardDetailSection.ledger)
                      _buildLedgerSection(context)
                    else
                      _buildRewardsSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).primaryColor;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        backgroundColor: isSelected ? primary : Colors.white,
        side: BorderSide(color: isSelected ? primary : Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildLedgerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ultimos movimientos',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isLoadingLedger && _ledgerEntries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Loader(),
          )
        else if (_ledgerError != null)
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
                'Aun no tienes movimientos recientes en esta tarjeta.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ledgerEntries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) =>
                _buildLedgerItem(_ledgerEntries[index]),
          ),
      ],
    );
  }

  Widget _buildRewardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rewards disponibles',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isLoadingRewards && _rewards.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Loader(),
          )
        else if (_rewardsError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ErrorView(
              message: _rewardsError!,
              onRetry: () => _loadRewards(refresh: true),
            ),
          )
        else if (_rewards.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                'No hay rewards activas para esta tarjeta.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rewards.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildRewardItem(_rewards[index]),
          ),
      ],
    );
  }

  Widget _buildRewardItem(ClientReward reward) {
    final createdAt = reward.createdAt != null
        ? DateFormat('dd MMM yyyy').format(reward.createdAt!.toLocal())
        : null;
    final rewardName = reward.name.trim().isEmpty ? 'Reward' : reward.name;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showRewardRedeemHint(rewardName),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
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
                  color: Colors.orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.redeem, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rewardName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reward.type,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Alta: $createdAt',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${reward.pointsCost} pts',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Toca para canjear',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRewardRedeemHint(String rewardName) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Como canjear'),
          content: Text(
            'Pidele al encargado que quieres canjear "$rewardName". '
            'El sabra que hacer en caja.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLedgerItem(LedgerEntry entry) {
    final isEarn = entry.type == 'EARN';
    final isRedeem = entry.type == 'REDEEM';

    final color = isEarn
        ? Colors.green
        : (isRedeem ? Colors.orange : Colors.blue);
    final icon = isEarn
        ? Icons.add_circle_outline
        : (isRedeem ? Icons.remove_circle_outline : Icons.info_outline);
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
            color: Colors.black.withValues(alpha: 0.05),
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
              color: color.withValues(alpha: 0.1),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
