import 'package:flutter_test/flutter_test.dart';

import 'services/auth_service_test.dart' as auth_service_tests;
import 'services/firestore_service_test.dart' as firestore_service_tests;
import 'providers/auth_provider_test.dart' as auth_provider_tests;

void main() {
  group('Šahovska App Tests', () {
    group('Services', () {
      auth_service_tests.main();
      firestore_service_tests.main();
    });

    group('Providers', () {
      auth_provider_tests.main();
    });
  });
}