import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../constants/constants.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final Dio _refreshDio;

  AuthInterceptor(this._storageService, this._refreshDio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await _refreshDio.post(
            '${AppConstants.apiBaseUrl}/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200 && response.data != null) {
            final newAccessToken = response.data['accessToken'] as String;
            final newRefreshToken = response.data['refreshToken'] as String;

            await _storageService.saveAccessToken(newAccessToken);
            await _storageService.saveRefreshToken(newRefreshToken);

            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final dio = Dio();
            final retryResponse = await dio.request(
              options.path,
              options: Options(
                method: options.method,
                headers: options.headers,
                responseType: options.responseType,
                contentType: options.contentType,
              ),
              data: options.data,
              queryParameters: options.queryParameters,
            );
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          await _storageService.clearAll();
        }
      }
    }
    return super.onError(err, handler);
  }
}
