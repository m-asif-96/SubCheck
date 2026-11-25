import 'package:get/get.dart';
import '../controller/add_edit_subscription_controller.dart';

class AddEditSubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddEditSubscriptionController>(() => AddEditSubscriptionController());
  }
}
