import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/core/config/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('apiBaseUrl should resolve to a non-empty /api/v1 URL', () {
      expect(AppConstants.apiBaseUrl, isNotEmpty);
      expect(AppConstants.apiBaseUrl.endsWith('/api/v1'), isTrue);
    });

    test('termsUri should resolve to the public terms page', () {
      expect(
        AppConstants.termsUri?.toString(),
        'https://puntos-cybac.vercel.app/terms',
      );
    });
  });
}
