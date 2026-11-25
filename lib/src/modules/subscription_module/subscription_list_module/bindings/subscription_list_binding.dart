import 'package:get/get.dart';
import '../controller/subscription_list_controller.dart';

class SubscriptionListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionListController>(() => SubscriptionListController());
  }
}
