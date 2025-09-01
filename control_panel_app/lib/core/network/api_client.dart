import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import 'api_interceptors.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  
  ApiClient(Dio dio) {
    _dio = dio;
    _setupDioClient();
  }
  
  void _setupDioClient() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl.trim(),
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        ApiConstants.contentType: ApiConstants.applicationJson,
        ApiConstants.acceptLanguage: 'ar',
      },
    );
    
    _dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(_dio),
      if (const bool.fromEnvironment('DEBUG')) 
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
    ]);
  }
  
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    int retries = 2,
  }) async {
    int attempt = 0;
    DioException? lastError;
    while (attempt <= retries) {
      try {
        final response = await _dio.get(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
        return response;
      } on DioException catch (e) {
        lastError = e;
        // فقط أعد المحاولة على مهلات الاتصال أو أخطاء الشبكة المؤقتة
        final isTimeout = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout;
        final isNetwork = e.type == DioExceptionType.unknown;
        if (attempt < retries && (isTimeout || isNetwork)) {
          final delay = Duration(milliseconds: 300 * (1 << attempt));
          await Future.delayed(delay);
          attempt++;
          continue;
        }
        break;
      }
    }
    throw ApiException.fromDioError(lastError!);
  }
  
  // Future<Response> post(
  //   String path, {
  //   dynamic data,
  //   Map<String, dynamic>? queryParameters,
  //   Options? options,
  //   CancelToken? cancelToken,
  //   ProgressCallback? onSendProgress,
  //   ProgressCallback? onReceiveProgress,
  // }) async {
  //   try {
  //     final response = await _dio.post(
  //       path,
  //       data: data,
  //       queryParameters: queryParameters,
  //       options: options,
  //       cancelToken: cancelToken,
  //       onSendProgress: onSendProgress,
  //       onReceiveProgress: onReceiveProgress,
  //     );
  //     return response;
  //   } on DioException catch (e) {
  //     throw ApiException.fromDioError(e);
  //   }
  // }
    Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // طباعة البيانات للتطوير
      if (const bool.fromEnvironment('DEBUG') || true) { // مؤقتاً للتطوير
        print('🔵 POST Request to: $path');
        print('📦 Data: $data');
      }
      
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      if (const bool.fromEnvironment('DEBUG') || true) {
        print('✅ Response: ${response.data}');
      }
      
      return response;
    } on DioException catch (e) {
      // طباعة تفاصيل الخطأ
      if (e.response != null) {
        print('❌ Error Status: ${e.response?.statusCode}');
        print('❌ Error Data: ${e.response?.data}');
        
        // معالجة خاصة للخطأ 400
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          String errorMessage = 'طلب غير صحيح';
          
          if (errorData is Map) {
            // محاولة استخراج رسالة الخطأ
            errorMessage = errorData['message'] ?? 
                          errorData['error'] ?? 
                          errorData['errors']?.toString() ?? 
                          'طلب غير صحيح: تحقق من البيانات المدخلة';
            
            // إذا كانت هناك تفاصيل للأخطاء
            if (errorData['errors'] is Map) {
              final errors = errorData['errors'] as Map;
              final errorDetails = errors.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join(', ');
              errorMessage = 'أخطاء في: $errorDetails';
            }
          }
          
          throw ApiException(
            message: errorMessage,
            statusCode: 400,
          );
        }
      }
      
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
  
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
  
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
  
  Future<Response> upload(
    String path, {
    required FormData formData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: options ?? Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
  
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl.trim();
  }
  
  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }
  
  void clearHeaders() {
    _dio.options.headers.clear();
  }
}