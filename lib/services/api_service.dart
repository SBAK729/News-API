import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';

class ApiService {
  final Dio _dio = Dio();
  final Logger _logger = AppLogger.get();

  ApiService() {
    _dio.options.connectTimeout = const Duration(milliseconds: ApiConfig.connectTimeout);
    _dio.options.receiveTimeout = const Duration(milliseconds: ApiConfig.receiveTimeout);
    
    // Don't throw on 400 errors - handle them gracefully
    _dio.options.validateStatus = (status) {
      return status! < 500; // Accept 4xx errors as valid responses
    };
    
    // Add interceptors for logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.i('API Request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i('API Response: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        _logger.e('API Error: ${error.type} - ${error.message}');
        return handler.next(error);
      },
    ));
  }

  Future<dynamic> getNewsApiData(String endpoint, Map<String, dynamic>? params) async {
    try {
      final Map<String, dynamic> queryParams = {
        'apiKey': ApiConfig.newsApiKey,
        ...?params,
      };

      // Remove any null values
      queryParams.removeWhere((key, value) => value == null);

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 400) {
        // Handle bad request specifically
        final errorData = response.data;
        throw Exception('NewsAPI Bad Request: ${errorData['message'] ?? 'Invalid parameters'}');
      } else {
        throw Exception('Failed to load data from NewsAPI: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        AppLogger.apiError('NewsAPI', 'Bad Request - check parameters');
        throw Exception('Invalid request parameters for NewsAPI');
      }
      AppLogger.apiError('NewsAPI', e.message ?? 'Unknown error');
      rethrow;
    }
  }

  Future<dynamic> getGuardianData(String endpoint, Map<String, dynamic>? params) async {
    try {
      final Map<String, dynamic> queryParams = {
        'api-key': ApiConfig.guardianApiKey,
        'show-fields': 'thumbnail,trailText,body', // Fixed fields parameter
        ...?params,
      };

      // Remove any null values and empty strings
      queryParams.removeWhere((key, value) => value == null || value == '');

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load data from Guardian: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.apiError('GuardianAPI', e.message ?? 'Unknown error');
      rethrow;
    }
  }

  Future<dynamic> getNewsDataIo(String endpoint, Map<String, dynamic>? params) async {
    try {
      final Map<String, dynamic> queryParams = {
        'apikey': ApiConfig.newsDataApiKey,
        ...?params,
      };

      // Remove any null values
      queryParams.removeWhere((key, value) => value == null);

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load data from NewsData.io: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.apiError('NewsData.io', e.message ?? 'Unknown error');
      rethrow;
    }
  }
}
