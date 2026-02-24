import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/presentation/pages/home_page.dart';
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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: HomePage(dependencies: _dependencies),
    );
  }
}
