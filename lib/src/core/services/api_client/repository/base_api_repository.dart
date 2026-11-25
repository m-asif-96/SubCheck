import '../i_api_client.dart';

abstract class BaseApiRepository {
  final IApiClient apiClient;

  BaseApiRepository(this.apiClient);
}
