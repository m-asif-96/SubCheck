import 'package:get/get.dart';
import '../../../../core/routes/app_pages.dart';

class DashboardController extends GetxController {
  final currentTabIndex = 0.obs;

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  void openAddSubscription() {
    Get.toNamed(AppRoutes.addSubscription);
  }
}
