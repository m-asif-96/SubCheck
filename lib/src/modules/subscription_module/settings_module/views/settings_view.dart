import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/custom_widgets/custom_card.dart';
import '../controller/settings_controller.dart';
import '../widgets/premium_banner_card.dart';
import '../widgets/settings_tile.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppConstants.settingsTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Upgrade to Pro Banner
            Obx(() => PremiumBannerCard(
                  isPremium: controller.mainApp.isPremium.value,
                  onUpgrade: controller.upgradeToPremium,
                )),

            const SizedBox(height: 24),

            // 2. Preferences Group
            Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            CustomCard(
              padding: EdgeInsets.zero,
              borderRadius: 20,
              child: Column(
                children: [
                  // Currency Picker
                  Obx(() => SettingsTile(
                        icon: Icons.currency_exchange_rounded,
                        iconColor: AppColors.primary,
                        title: AppConstants.prefCurrency,
                        subtitle: '${controller.mainApp.currency.value} (${controller.mainApp.currencySymbol.value})',
                        onTap: () => _showCurrencyDialog(context),
                      )),

                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),

                  // Dark Mode Toggle
                  Obx(() => SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        iconColor: AppColors.purple,
                        title: 'Dark Mode',
                        subtitle: controller.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                        trailing: Switch.adaptive(
                          value: controller.isDarkMode,
                          activeTrackColor: AppColors.primary,
                          onChanged: controller.toggleTheme,
                        ),
                      )),

                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),

                  // Notification Toggle
                  Obx(() => SettingsTile(
                        icon: Icons.notifications_active_rounded,
                        iconColor: AppColors.accent,
                        title: 'Renewal Alerts',
                        subtitle: 'Remind 2 days before due date',
                        trailing: Switch.adaptive(
                          value: controller.mainApp.notificationsEnabled.value,
                          activeTrackColor: AppColors.accent,
                          onChanged: controller.toggleNotifications,
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Information & About
            Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            CustomCard(
              padding: EdgeInsets.zero,
              borderRadius: 20,
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.cyan,
                    title: 'About SubCheck',
                    subtitle: 'Version ${AppConstants.appVersion}',
                    onTap: () => controller.showAboutDialog(context),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  SettingsTile(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.accent,
                    title: 'Privacy Policy',
                    subtitle: 'Your data stays on your device',
                    onTap: () => controller.showAboutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Default Currency',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.currencies.length,
                    itemBuilder: (context, index) {
                      final curr = controller.currencies[index];
                      final isSelected = controller.mainApp.currency.value == curr['code'];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Text(
                          curr['symbol']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          curr['name']!,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded, color: AppColors.primary)
                            : Text(
                                curr['code']!,
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                        onTap: () {
                          controller.setCurrency(curr['code']!, curr['symbol']!);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
