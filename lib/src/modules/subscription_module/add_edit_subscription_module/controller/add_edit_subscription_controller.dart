import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common/main_app_controller/main_app_controller.dart';
import '../../../../core/common/widgets/custom_snack_bar.dart';
import '../../../../core/models/subscription_model.dart';

class ServicePreset {
  final String name;
  final double defaultPrice;
  final SubscriptionCategory category;
  final BillingCycle cycle;
  final String colorHex;

  const ServicePreset({
    required this.name,
    required this.defaultPrice,
    required this.category,
    required this.cycle,
    required this.colorHex,
  });
}

class AddEditSubscriptionController extends GetxController {
  final MainAppController _mainApp = Get.find<MainAppController>();

  // Text Controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final notesController = TextEditingController();

  // Reactive State
  final selectedCurrency = 'USD'.obs;
  final selectedCurrencySymbol = '\$'.obs;
  final selectedCycle = BillingCycle.monthly.obs;
  final nextPaymentDate = DateTime.now().add(const Duration(days: 30)).obs;
  final selectedCategory = SubscriptionCategory.entertainment.obs;
  final reminderEnabled = true.obs;
  final brandColorHex = RxnString('#4F46E5');
  final isEditing = false.obs;
  final editingId = RxnString();
  final isLoading = false.obs;

  final formKey = GlobalKey<FormState>();

  // Currencies available
  final List<Map<String, String>> currencyOptions = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'PKR', 'symbol': '₨', 'name': 'Pakistani Rupee'},
  ];

  // Presets for quick selection
  final List<ServicePreset> presets = const [
    ServicePreset(name: 'Netflix', defaultPrice: 15.49, category: SubscriptionCategory.entertainment, cycle: BillingCycle.monthly, colorHex: '#E50914'),
    ServicePreset(name: 'Spotify', defaultPrice: 10.99, category: SubscriptionCategory.music, cycle: BillingCycle.monthly, colorHex: '#1DB954'),
    ServicePreset(name: 'iCloud+', defaultPrice: 9.99, category: SubscriptionCategory.cloud, cycle: BillingCycle.monthly, colorHex: '#0070C9'),
    ServicePreset(name: 'ChatGPT', defaultPrice: 20.00, category: SubscriptionCategory.productivity, cycle: BillingCycle.monthly, colorHex: '#10A37F'),
    ServicePreset(name: 'YouTube', defaultPrice: 13.99, category: SubscriptionCategory.entertainment, cycle: BillingCycle.monthly, colorHex: '#FF0000'),
    ServicePreset(name: 'Figma', defaultPrice: 12.00, category: SubscriptionCategory.productivity, cycle: BillingCycle.monthly, colorHex: '#F24E1E'),
    ServicePreset(name: 'GitHub', defaultPrice: 10.00, category: SubscriptionCategory.productivity, cycle: BillingCycle.monthly, colorHex: '#6E40C9'),
    ServicePreset(name: 'Prime', defaultPrice: 14.99, category: SubscriptionCategory.shopping, cycle: BillingCycle.monthly, colorHex: '#FF9900'),
  ];

  @override
  void onInit() {
    super.onInit();
    selectedCurrency.value = _mainApp.currency.value;
    selectedCurrencySymbol.value = _mainApp.currencySymbol.value;

    final dynamic args = Get.arguments;
    if (args is SubscriptionModel) {
      isEditing.value = true;
      editingId.value = args.id;
      nameController.text = args.name;
      priceController.text = args.price.toStringAsFixed(2);
      notesController.text = args.notes ?? '';
      selectedCurrency.value = args.currency;
      selectedCurrencySymbol.value = args.currencySymbol;
      selectedCycle.value = args.billingCycle;
      nextPaymentDate.value = args.nextPaymentDate;
      selectedCategory.value = args.category;
      reminderEnabled.value = args.reminderEnabled;
      brandColorHex.value = args.brandColorHex ?? '#4F46E5';
    }
  }

  void selectPreset(ServicePreset preset) {
    nameController.text = preset.name;
    priceController.text = preset.defaultPrice.toStringAsFixed(2);
    selectedCategory.value = preset.category;
    selectedCycle.value = preset.cycle;
    brandColorHex.value = preset.colorHex;
  }

  void setCategory(SubscriptionCategory cat) {
    selectedCategory.value = cat;
  }

  void setCycle(BillingCycle cycle) {
    selectedCycle.value = cycle;
  }

  void setPaymentDate(DateTime date) {
    nextPaymentDate.value = date;
  }

  void selectCurrency(String code, String symbol) {
    selectedCurrency.value = code;
    selectedCurrencySymbol.value = symbol;
  }

  Future<void> saveSubscription() async {
    final name = nameController.text.trim();
    final priceStr = priceController.text.trim().replaceAll(',', '.');

    if (name.isEmpty) {
      CustomSnackBar.showError('Please enter a subscription name');
      return;
    }

    final price = double.tryParse(priceStr);
    if (price == null || price <= 0) {
      CustomSnackBar.showError('Please enter a valid price greater than 0');
      return;
    }

    isLoading.value = true;
    try {
      if (isEditing.value && editingId.value != null) {
        final updated = SubscriptionModel(
          id: editingId.value!,
          name: name,
          price: price,
          currency: selectedCurrency.value,
          currencySymbol: selectedCurrencySymbol.value,
          billingCycle: selectedCycle.value,
          nextPaymentDate: nextPaymentDate.value,
          category: selectedCategory.value,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
          isActive: true,
          reminderEnabled: reminderEnabled.value,
          brandColorHex: brandColorHex.value,
        );
        await _mainApp.updateSubscription(updated);
        CustomSnackBar.showSuccess('Subscription updated successfully');
      } else {
        final newSub = SubscriptionModel(
          id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          price: price,
          currency: selectedCurrency.value,
          currencySymbol: selectedCurrencySymbol.value,
          billingCycle: selectedCycle.value,
          nextPaymentDate: nextPaymentDate.value,
          category: selectedCategory.value,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
          isActive: true,
          reminderEnabled: reminderEnabled.value,
          brandColorHex: brandColorHex.value,
        );
        await _mainApp.addSubscription(newSub);
        CustomSnackBar.showSuccess('Subscription added successfully');
      }
      Get.back();
    } catch (e) {
      CustomSnackBar.showError('Failed to save subscription: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
