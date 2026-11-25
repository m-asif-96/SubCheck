import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/custom_widgets/empty_state_widget.dart';
import '../controller/insights_controller.dart';
import '../widgets/category_pie_chart_widget.dart';
import '../widgets/monthly_yearly_projection_card.dart';
import '../widgets/top_category_highlight_card.dart';

class InsightsView extends GetView<InsightsController> {
  const InsightsView({super.key});

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
          AppConstants.insightsTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Obx(() {
        final totalMonthly = controller.totalMonthlySpend;
        final totalYearly = controller.totalYearlySpend;
        final currencySymbol = controller.currencySymbol;
        final categorySpendings = controller.categorySpendings;
        final topCategory = controller.topCategoryItem;

        if (totalMonthly <= 0) {
          return EmptyStateWidget(
            icon: Icons.pie_chart_outline_rounded,
            title: 'No spending insights yet',
            description: 'Add subscriptions to visualize your category breakdown and annual projections.',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Projections Card (Monthly vs Yearly)
              MonthlyYearlyProjectionCard(
                monthlySpend: totalMonthly,
                yearlySpend: totalYearly,
                currencySymbol: currencySymbol,
              ),

              const SizedBox(height: 16),

              // 2. Highest Spending Category Highlight
              if (topCategory != null) ...[
                TopCategoryHighlightCard(
                  item: topCategory,
                  currencySymbol: currencySymbol,
                ),
                const SizedBox(height: 16),
              ],

              // 3. Category Pie Chart Breakdown
              CategoryPieChartWidget(
                items: categorySpendings,
                totalSpend: totalMonthly,
                currencySymbol: currencySymbol,
              ),
            ],
          ),
        );
      }),
    );
  }
}
