class ApiRequest {
  final String url;
  final String method;
  final Map<String, dynamic>? queryParameters;
  final dynamic data;
  final Map<String, dynamic>? headers;

  const ApiRequest({
    required this.url,
    this.method = 'GET',
    this.queryParameters,
    this.data,
    this.headers,
  });
}
