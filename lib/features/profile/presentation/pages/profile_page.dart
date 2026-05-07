import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/di/app_dependencies.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/ui/widgets/error_view.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../../../features/auth/presentation/pages/magic_link_entry_page.dart';
import '../../data/repositories/client_repository.dart';
import '../../domain/models/client_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<ClientProfileResult> _profileFuture;
  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = widget.dependencies.getProfileUseCase();
    });
  }

  Future<void> _logout() async {
    await widget.dependencies.tokenStorageService.deleteToken();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            MagicLinkEntryPage(dependencies: widget.dependencies),
      ),
      (route) => false,
    );
  }

  Future<void> _openTermsAndConditions() async {
    await _openExternalUri(
      AppConstants.termsUri,
      missingMessage:
          'Configura TERMS_URL para abrir los términos y condiciones.',
    );
  }

  Future<void> _openPublicAccountDeletionPage() async {
    await _openExternalUri(
      AppConstants.accountDeletionUri,
      missingMessage:
          'No se pudo resolver la página pública de eliminación de cuenta.',
    );
  }

  Future<void> _openExternalUri(
    Uri? uri, {
    required String missingMessage,
  }) async {
    if (uri == null) {
      _showSnackBar(missingMessage);
      return;
    }

    final opened = await widget.dependencies.externalLinkService.open(uri);
    if (!opened && mounted) {
      _showSnackBar('No se pudo abrir el enlace solicitado.');
    }
  }

  Future<void> _deleteAccount() async {
    final reason = await _promptDeletionReason();
    if (reason == null) {
      return;
    }

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      await widget.dependencies.deleteAccountUseCase(reason: reason);
      await widget.dependencies.tokenStorageService.deleteToken();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              MagicLinkEntryPage(dependencies: widget.dependencies),
        ),
        (route) => false,
      );
    } on ApiClientException catch (error) {
      if (error.statusCode == 401 ||
          error.errorCode == 'CLIENT_UNAUTHENTICATED') {
        await _logout();
        return;
      }

      if (mounted) {
        _showSnackBar('No se pudo eliminar la cuenta: ${error.message}');
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Ocurrió un error inesperado al eliminar la cuenta.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }

  Future<String?> _promptDeletionReason() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Eliminar cuenta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Esta acción revocará tus accesos y anonimizará tus datos personales. Indica el motivo para continuar.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      labelText: 'Motivo',
                      alignLabelWithHint: true,
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final reason = controller.text.trim();
                    if (reason.isEmpty) {
                      setDialogState(() {
                        errorText = 'Ingresa un motivo para continuar.';
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop(reason);
                  },
                  child: const Text('Eliminar cuenta'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: FutureBuilder<ClientProfileResult>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            if (error is ApiClientException && error.statusCode == 401) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _logout());
              return const Loader();
            }

            return ErrorView(
              message: 'Error al cargar perfil: ${snapshot.error}',
              onRetry: _loadProfile,
            );
          }

          final data = snapshot.data!;
          final profile = data.profile;
          final activeCards = data.memberships
              .where((membership) => membership.status == 'ACTIVE')
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isDeletingAccount) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 16),
                ],
                _buildProfileHeader(profile),
                const SizedBox(height: 32),
                _buildStatsCard(activeCards),
                const SizedBox(height: 24),
                _buildSectionTitle('Documentos'),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.description_outlined,
                  title: 'Términos y condiciones',
                  subtitle: AppConstants.termsUri == null
                      ? 'Abrir PDF o enlace externo cuando TERMS_URL esté configurado.'
                      : 'Abrir PDF o página externa de términos.',
                  onTap: _isDeletingAccount ? null : _openTermsAndConditions,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Cuenta'),
                const SizedBox(height: 12),
                _buildAccountDeletionCard(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isDeletingAccount ? null : _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ClientProfile profile) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getInitials(profile.fullName),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          profile.fullName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (profile.email.isNotEmpty)
          Text(
            profile.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        if (profile.phone.isNotEmpty)
          Text(
            profile.phone,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'ID perfil: ${profile.id}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copiar ID',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(ClipboardData(text: profile.id));
                  messenger.showSnackBar(
                    const SnackBar(content: Text('ID de perfil copiado')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(int activeCards) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Tarjetas activas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          Text(
            activeCards.toString(),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Future<void> Function()? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.open_in_new),
        onTap: onTap == null ? null : () => onTap(),
      ),
    );
  }

  Widget _buildAccountDeletionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eliminar cuenta',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Si decides eliminar tu cuenta, revocaremos tus accesos y anonimizaremos tus datos personales asociados a la app.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.red[900]),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _isDeletingAccount
                    ? null
                    : _openPublicAccountDeletionPage,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Abrir página pública'),
              ),
              OutlinedButton.icon(
                onPressed: _isDeletingAccount ? null : _deleteAccount,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Eliminar cuenta',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
