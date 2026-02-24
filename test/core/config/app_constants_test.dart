import 'package:flutter_test/flutter_test.dart';
import 'package:puntos_cybac_mobile/core/config/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('apiBaseUrl should not have a hardcoded insecure default', () {
      // It should not be the old insecure default
      expect(AppConstants.apiBaseUrl, isNot('http://10.0.2.2:8000/api/v1'));
    });
  });
}
