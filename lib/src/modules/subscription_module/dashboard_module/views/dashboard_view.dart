import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../controller/dashboard_controller.dart';
import '../../home_module/views/home_view.dart';
import '../../subscription_list_module/views/subscription_list_view.dart';
import '../../insights_module/views/insights_view.dart';
import '../../settings_module/views/settings_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = const [
      HomeView(),
      SubscriptionListView(),
      InsightsView(),
      SettingsView(),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Obx(() => IndexedStack(
            index: controller.currentTabIndex.value,
            children: pages,
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.openAddSubscription,
        backgroundColor: AppColors.primary,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(() {
        final currentIndex = controller.currentTabIndex.value;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildNavItem(
                      index: 0,
                      currentIndex: currentIndex,
                      icon: Icons.home_rounded,
                      inactiveIcon: Icons.home_outlined,
                      label: AppConstants.navHome,
                      isDark: isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 1,
                      currentIndex: currentIndex,
                      icon: Icons.credit_card_rounded,
                      inactiveIcon: Icons.credit_card_outlined,
                      label: AppConstants.navSubscriptions,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 44), // Gap for docked FloatingActionButton
                  Expanded(
                    child: _buildNavItem(
                      index: 2,
                      currentIndex: currentIndex,
                      icon: Icons.pie_chart_rounded,
                      inactiveIcon: Icons.pie_chart_outline_rounded,
                      label: AppConstants.navInsights,
                      isDark: isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 3,
                      currentIndex: currentIndex,
                      icon: Icons.settings_rounded,
                      inactiveIcon: Icons.settings_outlined,
                      label: AppConstants.navSettings,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData inactiveIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = index == currentIndex;

    return InkWell(
      onTap: () => controller.changeTab(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? icon : inactiveIcon,
              size: 22,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
