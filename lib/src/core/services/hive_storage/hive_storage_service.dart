import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/subscription_model.dart';

class HiveStorageService {
  static const String _encryptionKeyName = 'subcheck_hive_aes256_key_v1';
  static const String _subscriptionsBoxName = 'subcheck_subscriptions_encrypted_v1';
  static const String _preferencesBoxName = 'subcheck_preferences_encrypted_v1';

  Box<Map>? _subscriptionsBox;
  Box? _preferencesBox;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  Box<Map>? get subscriptionsBox => _subscriptionsBox;
  Box? get preferencesBox => _preferencesBox;

  /// Initializes Hive, secures AES-256 key via Keystore/Keychain, opens encrypted boxes
  Future<void> init({bool isTest = false}) async {
    if (_initialized) return;

    List<int> encryptionKey;

    if (isTest) {
      final tempDir = Directory.systemTemp.createTempSync('hive_subcheck_test');
      Hive.init(tempDir.path);
      encryptionKey = Hive.generateSecureKey();
    } else {
      // 1. Initialize Hive for Flutter
      await Hive.initFlutter();

      // 2. Retrieve or generate AES-256 32-byte encryption key
      const secureStorage = FlutterSecureStorage();

      try {
        final storedKey = await secureStorage.read(key: _encryptionKeyName);
        if (storedKey != null && storedKey.isNotEmpty) {
          encryptionKey = base64Url.decode(storedKey);
        } else {
          encryptionKey = Hive.generateSecureKey();
          await secureStorage.write(
            key: _encryptionKeyName,
            value: base64UrlEncode(encryptionKey),
          );
        }
      } catch (e) {
        debugPrint('Warning: Secure storage fallback triggered for Hive encryption key: $e');
        encryptionKey = Hive.generateSecureKey();
      }
    }

    final cipher = HiveAesCipher(encryptionKey);

    // 3. Open encrypted boxes
    _subscriptionsBox = await Hive.openBox<Map>(
      _subscriptionsBoxName,
      encryptionCipher: cipher,
    );

    _preferencesBox = await Hive.openBox(
      _preferencesBoxName,
      encryptionCipher: cipher,
    );

    _initialized = true;

    // 4. One-time automated migration from legacy SharedPreferences cache (in non-test environments)
    if (!isTest) {
      await _migrateFromSharedPreferences();
    }
  }

  /// Automatically migrates any legacy unencrypted SharedPreferences data
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final sp = await SharedPreferences.getInstance();
      const legacyCacheKey = 'subcheck_subscriptions_cache_v1';
      const legacyPrefsKey = 'subcheck_user_preferences_v1';

      if (_subscriptionsBox != null && _subscriptionsBox!.isEmpty) {
        final legacyCached = sp.getString(legacyCacheKey);
        if (legacyCached != null && legacyCached.isNotEmpty) {
          final List<dynamic> list = jsonDecode(legacyCached);
          for (final item in list) {
            if (item is Map) {
              final map = Map<String, dynamic>.from(item);
              final id = map['id'] as String?;
              if (id != null) {
                await _subscriptionsBox!.put(id, map);
              }
            }
          }
          await sp.remove(legacyCacheKey);
        } else {
          // If first launch and completely empty, seed initial demo subscriptions
          for (final sub in _defaultSeedSubscriptions()) {
            await _subscriptionsBox!.put(sub.id, sub.toJson());
          }
        }
      }

      if (_preferencesBox != null && _preferencesBox!.isEmpty) {
        final legacyPrefs = sp.getString(legacyPrefsKey);
        if (legacyPrefs != null && legacyPrefs.isNotEmpty) {
          final Map<String, dynamic> prefs = jsonDecode(legacyPrefs);
          for (final entry in prefs.entries) {
            await _preferencesBox!.put(entry.key, entry.value);
          }
          await sp.remove(legacyPrefsKey);
        } else {
          await _preferencesBox!.putAll({
            'currency': 'USD',
            'currencySymbol': '\$',
            'themeMode': 'system',
            'notificationsEnabled': true,
            'reminderDaysBefore': 2,
            'isPremium': false,
          });
        }
      }
    } catch (e) {
      debugPrint('Error during legacy SharedPreferences migration: $e');
    }
  }

  // --- Subscriptions Fast Operations (O(1) Indexed) ---

  List<SubscriptionModel> getAllSubscriptions() {
    if (!_initialized || _subscriptionsBox == null) {
      return _defaultSeedSubscriptions();
    }

    final list = <SubscriptionModel>[];
    for (final raw in _subscriptionsBox!.values) {
      try {
        final map = Map<String, dynamic>.from(raw);
        list.add(SubscriptionModel.fromJson(map));
      } catch (e) {
        debugPrint('Failed to parse subscription from Hive: $e');
      }
    }
    // Return sorted by next payment date
    list.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));
    return list;
  }

  SubscriptionModel? getSubscriptionById(String id) {
    if (!_initialized || _subscriptionsBox == null) {
      return _defaultSeedSubscriptions().firstWhere(
        (s) => s.id == id,
        orElse: () => _defaultSeedSubscriptions().first,
      );
    }
    final raw = _subscriptionsBox!.get(id);
    if (raw == null) return null;
    return SubscriptionModel.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> saveSubscription(SubscriptionModel sub) async {
    if (!_initialized || _subscriptionsBox == null) return;
    await _subscriptionsBox!.put(sub.id, sub.toJson());
  }

  Future<bool> deleteSubscription(String id) async {
    if (!_initialized || _subscriptionsBox == null) return false;
    if (_subscriptionsBox!.containsKey(id)) {
      await _subscriptionsBox!.delete(id);
      return true;
    }
    return false;
  }

  Future<void> clearAllSubscriptions() async {
    if (!_initialized || _subscriptionsBox == null) return;
    await _subscriptionsBox!.clear();
  }

  // --- Preferences Fast Operations (O(1)) ---

  Map<String, dynamic> getAllPreferences() {
    if (!_initialized || _preferencesBox == null) {
      return {
        'currency': 'USD',
        'currencySymbol': '\$',
        'themeMode': 'system',
        'notificationsEnabled': true,
        'reminderDaysBefore': 2,
        'isPremium': false,
      };
    }

    final map = <String, dynamic>{};
    for (final key in _preferencesBox!.keys) {
      map[key.toString()] = _preferencesBox!.get(key);
    }
    // Default fallbacks
    if (!map.containsKey('currency')) map['currency'] = 'USD';
    if (!map.containsKey('currencySymbol')) map['currencySymbol'] = '\$';
    if (!map.containsKey('themeMode')) map['themeMode'] = 'system';
    if (!map.containsKey('notificationsEnabled')) map['notificationsEnabled'] = true;
    if (!map.containsKey('isPremium')) map['isPremium'] = false;
    return map;
  }

  Future<void> saveAllPreferences(Map<String, dynamic> prefs) async {
    if (!_initialized || _preferencesBox == null) return;
    await _preferencesBox!.putAll(prefs);
  }

  T? getPreference<T>(String key, {T? defaultValue}) {
    if (!_initialized || _preferencesBox == null) return defaultValue;
    return _preferencesBox!.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> setPreference(String key, dynamic value) async {
    if (!_initialized || _preferencesBox == null) return;
    await _preferencesBox!.put(key, value);
  }

  // --- Backup & Restore (Zero-Cloud Privacy Backup) ---

  String exportBackupJson() {
    final subs = getAllSubscriptions().map((s) => s.toJson()).toList();
    final prefs = getAllPreferences();
    final backup = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'subscriptions': subs,
      'preferences': prefs,
    };
    return jsonEncode(backup);
  }

  Future<bool> importBackupJson(String jsonString) async {
    if (!_initialized || _subscriptionsBox == null || _preferencesBox == null) {
      return false;
    }
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      if (data.containsKey('subscriptions')) {
        final List<dynamic> subsList = data['subscriptions'];
        for (final item in subsList) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            final id = map['id'] as String?;
            if (id != null) {
              await _subscriptionsBox!.put(id, map);
            }
          }
        }
      }
      if (data.containsKey('preferences')) {
        final Map<String, dynamic> prefsMap = Map<String, dynamic>.from(data['preferences']);
        await _preferencesBox!.putAll(prefsMap);
      }
      return true;
    } catch (e) {
      debugPrint('Failed to import backup: $e');
      return false;
    }
  }

  List<SubscriptionModel> _defaultSeedSubscriptions() {
    final now = DateTime.now();
    return [
      SubscriptionModel(
        id: 'sub_netflix',
        name: 'Netflix Standard',
        price: 15.49,
        currency: 'USD',
        currencySymbol: '\$',
        billingCycle: BillingCycle.monthly,
        nextPaymentDate: now.add(const Duration(days: 3)),
        category: SubscriptionCategory.entertainment,
        notes: 'Family 4K plan, split with Alex',
        isActive: true,
        reminderEnabled: true,
        reminderDaysBefore: 2,
        brandColorHex: '#E50914',
      ),
      SubscriptionModel(
        id: 'sub_spotify',
        name: 'Spotify Premium',
        price: 10.99,
        currency: 'USD',
        currencySymbol: '\$',
        billingCycle: BillingCycle.monthly,
        nextPaymentDate: now.add(const Duration(days: 6)),
        category: SubscriptionCategory.music,
        notes: 'Individual student / standard tier',
        isActive: true,
        reminderEnabled: true,
        reminderDaysBefore: 1,
        brandColorHex: '#1DB954',
      ),
      SubscriptionModel(
        id: 'sub_icloud',
        name: 'Apple iCloud+ 2TB',
        price: 9.99,
        currency: 'USD',
        currencySymbol: '\$',
        billingCycle: BillingCycle.monthly,
        nextPaymentDate: now.add(const Duration(days: 11)),
        category: SubscriptionCategory.cloud,
        notes: 'Backup for iPhone and Mac',
        isActive: true,
        reminderEnabled: true,
        reminderDaysBefore: 2,
        brandColorHex: '#0070C9',
      ),
      SubscriptionModel(
        id: 'sub_chatgpt',
        name: 'ChatGPT Plus',
        price: 20.00,
        currency: 'USD',
        currencySymbol: '\$',
        billingCycle: BillingCycle.monthly,
        nextPaymentDate: now.add(const Duration(days: 15)),
        category: SubscriptionCategory.productivity,
        notes: 'OpenAI GPT-4o & Canvas subscription',
        isActive: true,
        reminderEnabled: true,
        reminderDaysBefore: 3,
        brandColorHex: '#10A37F',
      ),
      SubscriptionModel(
        id: 'sub_figma',
        name: 'Figma Professional',
        price: 144.00,
        currency: 'USD',
        currencySymbol: '\$',
        billingCycle: BillingCycle.yearly,
        nextPaymentDate: now.add(const Duration(days: 21)),
        category: SubscriptionCategory.productivity,
        notes: 'Billed annually (\$12/month equivalent)',
        isActive: true,
        reminderEnabled: true,
        reminderDaysBefore: 7,
        brandColorHex: '#F24E1E',
      ),
      SubscriptionModel(
        id: 'sub_prime',
        name: 'Amazon Prime',
        price: 139.00,
        currency: 'USD',
        currencySymbol: '\$',
        billingCycle: BillingCycle.yearly,
        nextPaymentDate: now.add(const Duration(days: 28)),
        category: SubscriptionCategory.shopping,
        notes: 'Free 2-day delivery + Prime Video',
        isActive: true,
        reminderEnabled: true,
        reminderDaysBefore: 5,
        brandColorHex: '#FF9900',
      ),
      SubscriptionModel(
        id: 'sub_copilot',
        name: 'GitHub Copilot',
        price: 10.00,
        currency: 'USD',
        currencySymbol: '\$',
        billingCycle: BillingCycle.monthly,
        nextPaymentDate: now.add(const Duration(days: 2)),
        category: SubscriptionCategory.productivity,
        notes: 'AI pair programming tool',
        isActive: true,
        reminderEnabled: true,
        reminderDaysBefore: 1,
        brandColorHex: '#6E40C9',
      ),
      SubscriptionModel(
        id: 'sub_disney',
        name: 'Disney+ Bundle',
        price: 19.99,
        currency: 'USD',
        currencySymbol: '\$',
        billingCycle: BillingCycle.monthly,
        nextPaymentDate: now.add(const Duration(days: 19)),
        category: SubscriptionCategory.entertainment,
        notes: 'Disney+, Hulu & ESPN+',
        isActive: false,
        reminderEnabled: false,
        reminderDaysBefore: 2,
        brandColorHex: '#113CCF',
      ),
    ];
  }
}
