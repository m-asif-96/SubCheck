import 'package:get/get.dart';
import '../common/main_app_controller/main_app_controller.dart';
import '../services/api_client/api_client.dart';
import '../services/api_client/i_api_client.dart';
import '../services/api_client/repository/api_repository.dart';
import '../services/api_client/repository/i_api_repository.dart';
import '../services/hive_storage/hive_storage_service.dart';
import '../services/push_notification/push_notification_service.dart';
import '../services/secure_storage/secure_storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Permanent storage and push
    Get.put<SecureStorageService>(SecureStorageService(), permanent: true);
    Get.put<PushNotificationService>(PushNotificationService(), permanent: true);

    // Hive Storage (in case not already initialized in main/test)
    if (!Get.isRegistered<HiveStorageService>()) {
      Get.put<HiveStorageService>(HiveStorageService(), permanent: true);
    }

    // API Client and Repository
    Get.lazyPut<IApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<IApiRepository>(
      () => ApiRepository(Get.find<IApiClient>(), Get.find<HiveStorageService>()),
      fenix: true,
    );

    // Global Controller (permanent)
    Get.put<MainAppController>(MainAppController(), permanent: true);
  }
}
