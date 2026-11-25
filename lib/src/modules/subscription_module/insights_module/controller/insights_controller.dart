import 'package:get/get.dart';
import '../../../../core/common/main_app_controller/main_app_controller.dart';
import '../../../../core/models/subscription_model.dart';

class CategorySpendingItem {
  final SubscriptionCategory category;
  final double amount;
  final double percentage;

  const CategorySpendingItem({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class InsightsController extends GetxController {
  final MainAppController mainApp = Get.find<MainAppController>();

  double get totalMonthlySpend => mainApp.totalMonthlySpend;
  double get totalYearlySpend => mainApp.totalYearlySpend;
  String get currencySymbol => mainApp.currencySymbol.value;
  int get activeCount => mainApp.activeSubscriptions.length;

  List<CategorySpendingItem> get categorySpendings {
    final total = totalMonthlySpend;
    if (total == 0) return [];

    final map = mainApp.categoryBreakdown;
    final items = map.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return CategorySpendingItem(
        category: entry.key,
        amount: entry.value,
        percentage: percentage,
      );
    }).toList();

    items.sort((a, b) => b.amount.compareTo(a.amount));
    return items;
  }

  CategorySpendingItem? get topCategoryItem {
    final list = categorySpendings;
    if (list.isEmpty) return null;
    return list.first;
  }
}
