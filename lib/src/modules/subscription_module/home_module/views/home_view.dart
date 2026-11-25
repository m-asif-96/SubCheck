import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../controller/home_controller.dart';
import '../widgets/monthly_hero_card.dart';
import '../widgets/upcoming_payments_section.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.donut_large_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: controller.mainApp.toggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final monthlySpend = controller.totalMonthlySpend;
        final yearlySpend = controller.totalYearlySpend;
        final activeCount = controller.activeCount;
        final currencySymbol = controller.currencySymbol;
        final upcomingList = controller.upcomingPayments;

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Large Hero "Monthly Spend" Card
                MonthlyHeroCard(
                  monthlySpend: monthlySpend,
                  yearlySpend: yearlySpend,
                  activeCount: activeCount,
                  currencySymbol: currencySymbol,
                  onInsightsTap: controller.openAllSubscriptions,
                ),

                const SizedBox(height: 28),

                // 2. Upcoming Payments Section
                UpcomingPaymentsSection(
                  subscriptions: upcomingList,
                  onSeeAllTap: controller.openAllSubscriptions,
                  onSubscriptionTap: controller.openEditSubscription,
                  onAddTap: controller.openAddSubscription,
                ),

                const SizedBox(height: 80), // Padding for bottom bar & FAB
              ],
            ),
          ),
        );
      }),
    );
  }
}
