import 'package:get/get.dart';
import '../../../../core/common/main_app_controller/main_app_controller.dart';
import '../../../../core/models/subscription_model.dart';
import '../../../../core/routes/app_pages.dart';

class HomeController extends GetxController {
  final MainAppController mainApp = Get.find<MainAppController>();

  final isRefreshing = false.obs;

  List<SubscriptionModel> get upcomingPayments => mainApp.upcomingPayments;
  double get totalMonthlySpend => mainApp.totalMonthlySpend;
  double get totalYearlySpend => mainApp.totalYearlySpend;
  int get activeCount => mainApp.activeSubscriptions.length;
  String get currencySymbol => mainApp.currencySymbol.value;

  Future<void> onRefresh() async {
    isRefreshing.value = true;
    try {
      await mainApp.loadSubscriptions();
    } finally {
      isRefreshing.value = false;
    }
  }

  void openAddSubscription() {
    Get.toNamed(AppRoutes.addSubscription);
  }

  void openAllSubscriptions() {
    Get.toNamed(AppRoutes.subscriptions);
  }

  void openEditSubscription(SubscriptionModel subscription) {
    Get.toNamed(
      AppRoutes.editSubscription,
      arguments: subscription,
    );
  }
}
