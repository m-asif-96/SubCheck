import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common/main_app_controller/main_app_controller.dart';
import '../../../../core/common/widgets/custom_snack_bar.dart';

class SettingsController extends GetxController {
  final MainAppController mainApp = Get.find<MainAppController>();

  final List<Map<String, String>> currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'PKR', 'symbol': '₨', 'name': 'Pakistani Rupee'},
  ];

  bool get isDarkMode => mainApp.themeMode.value == ThemeMode.dark;

  void toggleTheme(bool dark) {
    mainApp.setThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  }

  void setCurrency(String code, String symbol) {
    mainApp.setCurrency(code, symbol);
    CustomSnackBar.showSuccess('Default currency set to $code ($symbol)');
  }

  void toggleNotifications(bool val) {
    mainApp.toggleNotifications(val);
    if (val) {
      CustomSnackBar.showInfo('Renewal notifications enabled');
    } else {
      CustomSnackBar.showInfo('Renewal notifications disabled');
    }
  }

  void upgradeToPremium() {
    mainApp.setPremium(true);
    CustomSnackBar.showSuccess('Welcome to SubCheck Pro! All premium features unlocked.');
  }

  void showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('SubCheck', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0 (Build 1)'),
            SizedBox(height: 10),
            Text(
              'A minimal, elegant subscription tracker built with Flutter and GetX layered module architecture.',
              style: TextStyle(height: 1.4),
            ),
            SizedBox(height: 14),
            Text(
              'Privacy First: Your subscription data is stored securely on your device. We do not sell or track your private financial records.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
