import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/app/di/app_dependencies.dart';
import 'package:puntos_cybac_mobile/core/config/app_constants.dart';

void main() {
  group('AppDependencies', () {
    test('create should throw ArgumentError if API_BASE_URL is not set', () {
      if (AppConstants.apiBaseUrl.isEmpty) {
        expect(() => AppDependencies.create(), throwsArgumentError);
      }
    });

    test('create should work if API_BASE_URL is provided', () {
      if (AppConstants.apiBaseUrl.isNotEmpty) {
        final dependencies = AppDependencies.create();
        expect(dependencies, isA<AppDependencies>());
        dependencies.dispose();
      }
    });
  });
}
