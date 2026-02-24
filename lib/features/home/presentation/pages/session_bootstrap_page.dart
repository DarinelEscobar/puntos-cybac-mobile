import 'package:flutter/material.dart';
import '../../../../app/di/app_dependencies.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/pages/magic_link_entry_page.dart';
import 'main_scaffold.dart';

class SessionBootstrapPage extends StatefulWidget {
  const SessionBootstrapPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<SessionBootstrapPage> createState() => _SessionBootstrapPageState();
}

class _SessionBootstrapPageState extends State<SessionBootstrapPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Artificial delay for splash effect and to ensure UI builds
    await Future.delayed(const Duration(milliseconds: 1500));

    // Check if token exists
    final token = await widget.dependencies.tokenStorageService.getToken();
    if (token == null || token.isEmpty) {
      _redirectToLogin();
      return;
    }

    try {
      // Fetch cards and profile
      await Future.wait([
         widget.dependencies.getMyCardsUseCase(),
         widget.dependencies.getProfileUseCase(),
      ]);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScaffold(dependencies: widget.dependencies),
          ),
        );
      }
    } on ApiClientException catch (e) {
      if (e.statusCode == 401 || e.errorCode == 'CLIENT_UNAUTHENTICATED') {
        _redirectToLogin();
      } else {
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.message}'),
                  action: SnackBarAction(label: 'Reintentar', onPressed: _bootstrap),
                  duration: const Duration(days: 1), // Stick until action
                ),
             );
        }
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error de conexión o inesperado.'),
              action: SnackBarAction(label: 'Reintentar', onPressed: _bootstrap),
              duration: const Duration(days: 1),
            ),
         );
       }
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MagicLinkEntryPage(dependencies: widget.dependencies),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ),
                Icon(Icons.loyalty, size: 40, color: Theme.of(context).primaryColor),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Iniciando Sesión',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparando tu tarjeta...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
             Container(
              width: 200,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.7, // Mock progress
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
             const SizedBox(height: 16),
             Text(
              'Esto solo tomará un momento',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
