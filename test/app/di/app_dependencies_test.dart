import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/app/di/app_dependencies.dart';
import 'package:puntos_cybac_mobile/core/config/app_constants.dart';

void main() {
  group('AppDependencies', () {
    test('create should work with resolved API_BASE_URL', () {
      expect(AppConstants.apiBaseUrl, isNotEmpty);
      final dependencies = AppDependencies.create();
      expect(dependencies, isA<AppDependencies>());
      dependencies.dispose();
    });
  });
}
