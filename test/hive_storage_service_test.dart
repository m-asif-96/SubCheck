import 'package:flutter_test/flutter_test.dart';
import 'package:sub_check/src/core/models/subscription_model.dart';
import 'package:sub_check/src/core/services/hive_storage/hive_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HiveStorageService storage;

  setUp(() async {
    storage = HiveStorageService();
    await storage.init(isTest: true);
  });

  tearDown(() async {
    await storage.clearAllSubscriptions();
  });

  test('HiveStorageService initializes encrypted boxes in test mode', () {
    expect(storage.isInitialized, isTrue);
    expect(storage.subscriptionsBox, isNotNull);
    expect(storage.preferencesBox, isNotNull);
  });

  test('HiveStorageService save, retrieve, and delete subscription', () async {
    final sub = SubscriptionModel(
      id: 'sub_test_123',
      name: 'Test Netflix',
      price: 19.99,
      billingCycle: BillingCycle.monthly,
      nextPaymentDate: DateTime(2026, 12, 1),
      category: SubscriptionCategory.entertainment,
    );

    await storage.saveSubscription(sub);

    final retrieved = storage.getSubscriptionById('sub_test_123');
    expect(retrieved, isNotNull);
    expect(retrieved!.name, 'Test Netflix');
    expect(retrieved.price, 19.99);

    final all = storage.getAllSubscriptions();
    expect(all.any((s) => s.id == 'sub_test_123'), isTrue);

    final deleted = await storage.deleteSubscription('sub_test_123');
    expect(deleted, isTrue);
    expect(storage.getSubscriptionById('sub_test_123'), isNull);
  });

  test('HiveStorageService preferences read and write', () async {
    await storage.setPreference('currency', 'PKR');
    await storage.setPreference('currencySymbol', '₨');

    final prefs = storage.getAllPreferences();
    expect(prefs['currency'], 'PKR');
    expect(prefs['currencySymbol'], '₨');
  });

  test('HiveStorageService backup export and import works cleanly', () async {
    final sub = SubscriptionModel(
      id: 'sub_backup_test',
      name: 'Backup Pro',
      price: 5.0,
      billingCycle: BillingCycle.monthly,
      nextPaymentDate: DateTime(2026, 11, 30),
      category: SubscriptionCategory.productivity,
    );

    await storage.saveSubscription(sub);
    final backupJson = storage.exportBackupJson();

    expect(backupJson, contains('sub_backup_test'));

    await storage.clearAllSubscriptions();
    expect(storage.getSubscriptionById('sub_backup_test'), isNull);

    final success = await storage.importBackupJson(backupJson);
    expect(success, isTrue);
    expect(storage.getSubscriptionById('sub_backup_test'), isNotNull);
    expect(storage.getSubscriptionById('sub_backup_test')!.name, 'Backup Pro');
  });
}
