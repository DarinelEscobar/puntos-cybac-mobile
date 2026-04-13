import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/ui/widgets/debug_build_badge.dart';
import '../features/home/presentation/pages/session_bootstrap_page.dart';
import 'di/app_dependencies.dart';

class PuntosCybacApp extends StatefulWidget {
  const PuntosCybacApp({super.key});

  @override
  State<PuntosCybacApp> createState() => _PuntosCybacAppState();
}

class _PuntosCybacAppState extends State<PuntosCybacApp> {
  late final AppDependencies _dependencies;

  @override
  void initState() {
    super.initState();
    _dependencies = AppDependencies.create();
  }

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puntos CYBAC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        if (!kDebugMode) {
          return content;
        }

        return Stack(
          children: [
            content,
            const Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                minimum: EdgeInsets.only(top: 12, right: 12),
                child: DebugBuildBadge(),
              ),
            ),
          ],
        );
      },
      home: SessionBootstrapPage(dependencies: _dependencies),
    );
  }
}
