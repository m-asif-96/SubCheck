import 'package:get/get.dart';
import '../../modules/subscription_module/dashboard_module/bindings/dashboard_binding.dart';
import '../../modules/subscription_module/dashboard_module/views/dashboard_view.dart';
import '../../modules/subscription_module/home_module/bindings/home_binding.dart';
import '../../modules/subscription_module/home_module/views/home_view.dart';
import '../../modules/subscription_module/subscription_list_module/bindings/subscription_list_binding.dart';
import '../../modules/subscription_module/subscription_list_module/views/subscription_list_view.dart';
import '../../modules/subscription_module/add_edit_subscription_module/bindings/add_edit_subscription_binding.dart';
import '../../modules/subscription_module/add_edit_subscription_module/views/add_edit_subscription_view.dart';
import '../../modules/subscription_module/insights_module/bindings/insights_binding.dart';
import '../../modules/subscription_module/insights_module/views/insights_view.dart';
import '../../modules/subscription_module/settings_module/bindings/settings_binding.dart';
import '../../modules/subscription_module/settings_module/views/settings_view.dart';

abstract class AppRoutes {
  static const dashboard = '/';
  static const home = '/home';
  static const subscriptions = '/subscriptions';
  static const addSubscription = '/add-subscription';
  static const editSubscription = '/edit-subscription';
  static const insights = '/insights';
  static const settings = '/settings';
}

class AppPages {
  static const initial = AppRoutes.dashboard;

  static final pages = [
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.subscriptions,
      page: () => const SubscriptionListView(),
      binding: SubscriptionListBinding(),
    ),
    GetPage(
      name: AppRoutes.addSubscription,
      page: () => const AddEditSubscriptionView(),
      binding: AddEditSubscriptionBinding(),
    ),
    GetPage(
      name: AppRoutes.editSubscription,
      page: () => const AddEditSubscriptionView(),
      binding: AddEditSubscriptionBinding(),
    ),
    GetPage(
      name: AppRoutes.insights,
      page: () => const InsightsView(),
      binding: InsightsBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
