import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';
import '../../home_module/controller/home_controller.dart';
import '../../subscription_list_module/controller/subscription_list_controller.dart';
import '../../insights_module/controller/insights_controller.dart';
import '../../settings_module/controller/settings_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SubscriptionListController>(() => SubscriptionListController());
    Get.lazyPut<InsightsController>(() => InsightsController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
