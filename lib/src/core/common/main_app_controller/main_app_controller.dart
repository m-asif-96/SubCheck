import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/subscription_model.dart';
import '../../services/api_client/repository/i_api_repository.dart';

class MainAppController extends GetxController {
  final IApiRepository _apiRepository = Get.find<IApiRepository>();

  final themeMode = ThemeMode.system.obs;
  final currency = 'USD'.obs;
  final currencySymbol = '\$'.obs;
  final isPremium = false.obs;
  final notificationsEnabled = true.obs;

  final subscriptions = <SubscriptionModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
    loadSubscriptions();
  }

  Future<void> loadPreferences() async {
    try {
      final prefs = await _apiRepository.getUserPreferences();
      currency.value = prefs['currency'] as String? ?? 'USD';
      currencySymbol.value = prefs['currencySymbol'] as String? ?? '\$';
      isPremium.value = prefs['isPremium'] as bool? ?? false;
      notificationsEnabled.value = prefs['notificationsEnabled'] as bool? ?? true;

      final themeStr = prefs['themeMode'] as String? ?? 'system';
      if (themeStr == 'dark') {
        themeMode.value = ThemeMode.dark;
      } else if (themeStr == 'light') {
        themeMode.value = ThemeMode.light;
      } else {
        themeMode.value = ThemeMode.system;
      }
    } catch (_) {}
  }

  Future<void> loadSubscriptions() async {
    isLoading.value = true;
    try {
      final list = await _apiRepository.getSubscriptions();
      subscriptions.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    _saveCurrentPreferences();
  }

  void toggleTheme() {
    if (themeMode.value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  void setCurrency(String code, String symbol) {
    currency.value = code;
    currencySymbol.value = symbol;
    _saveCurrentPreferences();
  }

  void toggleNotifications(bool enabled) {
    notificationsEnabled.value = enabled;
    _saveCurrentPreferences();
  }

  void setPremium(bool premium) {
    isPremium.value = premium;
    _saveCurrentPreferences();
  }

  Future<void> _saveCurrentPreferences() async {
    String themeStr = 'system';
    if (themeMode.value == ThemeMode.dark) themeStr = 'dark';
    if (themeMode.value == ThemeMode.light) themeStr = 'light';

    await _apiRepository.saveUserPreferences({
      'currency': currency.value,
      'currencySymbol': currencySymbol.value,
      'themeMode': themeStr,
      'notificationsEnabled': notificationsEnabled.value,
      'isPremium': isPremium.value,
    });
  }

  // Reactive calculations
  double get totalMonthlySpend {
    return subscriptions
        .where((s) => s.isActive)
        .fold(0.0, (sum, item) => sum + item.monthlyEquivalent);
  }

  double get totalYearlySpend => totalMonthlySpend * 12;

  List<SubscriptionModel> get activeSubscriptions {
    return subscriptions.where((s) => s.isActive).toList();
  }

  List<SubscriptionModel> get upcomingPayments {
    final active = activeSubscriptions;
    active.sort((a, b) => a.daysUntilPayment.compareTo(b.daysUntilPayment));
    // Filter to next 30 days
    return active.where((s) => s.daysUntilPayment >= 0 && s.daysUntilPayment <= 30).toList();
  }

  Map<SubscriptionCategory, double> get categoryBreakdown {
    final Map<SubscriptionCategory, double> map = {};
    for (final sub in activeSubscriptions) {
      map[sub.category] = (map[sub.category] ?? 0.0) + sub.monthlyEquivalent;
    }
    return map;
  }

  SubscriptionCategory? get highestSpendingCategory {
    final breakdown = categoryBreakdown;
    if (breakdown.isEmpty) return null;
    var highestEntry = breakdown.entries.first;
    for (final entry in breakdown.entries) {
      if (entry.value > highestEntry.value) {
        highestEntry = entry;
      }
    }
    return highestEntry.key;
  }

  Future<void> addSubscription(SubscriptionModel sub) async {
    await _apiRepository.createSubscription(sub);
    await loadSubscriptions();
  }

  Future<void> updateSubscription(SubscriptionModel sub) async {
    await _apiRepository.updateSubscription(sub);
    await loadSubscriptions();
  }

  Future<void> deleteSubscription(String id) async {
    await _apiRepository.deleteSubscription(id);
    await loadSubscriptions();
  }

  Future<void> toggleSubscriptionActive(String id) async {
    await _apiRepository.toggleSubscriptionStatus(id);
    await loadSubscriptions();
  }
}
