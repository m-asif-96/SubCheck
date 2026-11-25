import 'package:get/get.dart';
import '../../../models/subscription_model.dart';
import '../../hive_storage/hive_storage_service.dart';
import 'base_api_repository.dart';
import 'i_api_repository.dart';

class ApiRepository extends BaseApiRepository implements IApiRepository {
  final HiveStorageService _hiveStorage;

  ApiRepository(super.apiClient, [HiveStorageService? hiveStorage])
      : _hiveStorage = hiveStorage ?? Get.find<HiveStorageService>();

  @override
  Future<List<SubscriptionModel>> getSubscriptions() async {
    return _hiveStorage.getAllSubscriptions();
  }

  @override
  Future<SubscriptionModel> getSubscriptionById(String id) async {
    final found = _hiveStorage.getSubscriptionById(id);
    if (found != null) return found;
    throw Exception('Subscription not found with ID: $id');
  }

  @override
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription) async {
    await _hiveStorage.saveSubscription(subscription);
    return subscription;
  }

  @override
  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription) async {
    final existing = _hiveStorage.getSubscriptionById(subscription.id);
    if (existing == null) {
      throw Exception('Subscription not found: ${subscription.id}');
    }
    await _hiveStorage.saveSubscription(subscription);
    return subscription;
  }

  @override
  Future<bool> deleteSubscription(String id) async {
    return await _hiveStorage.deleteSubscription(id);
  }

  @override
  Future<SubscriptionModel> toggleSubscriptionStatus(String id) async {
    final current = _hiveStorage.getSubscriptionById(id);
    if (current != null) {
      final updated = current.copyWith(isActive: !current.isActive);
      await _hiveStorage.saveSubscription(updated);
      return updated;
    }
    throw Exception('Subscription not found: $id');
  }

  @override
  Future<Map<String, dynamic>> getUserPreferences() async {
    return _hiveStorage.getAllPreferences();
  }

  @override
  Future<void> saveUserPreferences(Map<String, dynamic> prefs) async {
    await _hiveStorage.saveAllPreferences(prefs);
  }
}
