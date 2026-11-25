import '../../../models/subscription_model.dart';

abstract class IApiRepository {
  Future<List<SubscriptionModel>> getSubscriptions();
  Future<SubscriptionModel> getSubscriptionById(String id);
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription);
  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription);
  Future<bool> deleteSubscription(String id);
  Future<SubscriptionModel> toggleSubscriptionStatus(String id);
  Future<Map<String, dynamic>> getUserPreferences();
  Future<void> saveUserPreferences(Map<String, dynamic> prefs);
}
