import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_task_2/core/storage/secure_storage.dart';

void main() {
  // Test secure storage caching mechanism
  group('StorageService Tests', () {
    late StorageService storageService;
    late SharedPreferences prefs;

    setUp(() async {
      // Mock Shared Preferences
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      // Mock Secure Storage (Mocking via setting channel mocks is possible, or we can use custom memory maps)
      // Since secure storage doesn't run natively in standard unit test contexts easily without package mocks,
      // we can verify the shared_preferences mapping layer.
      storageService = StorageService(
        secureStorage: const FlutterSecureStorage(),
        prefs: prefs,
      );
    });

    test('userData cache check', () async {
      final userMap = {
        'id': 'emp-admin-1',
        'email': 'admin@enterprise.com',
        'name': 'Sarah Jenkins',
        'role': 'admin',
        'department': 'HR',
      };

      await storageService.saveUserData(userMap);
      final fetched = storageService.getUserData();

      expect(fetched, isNotNull);
      expect(fetched!['email'], equals('admin@enterprise.com'));
      expect(fetched['role'], equals('admin'));

      await storageService.clearUserData();
      expect(storageService.getUserData(), isNull);
    });
  });
}
