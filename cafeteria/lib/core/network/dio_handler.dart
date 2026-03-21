import 'dart:developer';
import 'package:dio/dio.dart';
import '../constants/api.dart';

class NetworkDioHandler {
  static NetworkDioHandler? _instance;

  factory NetworkDioHandler() {
    _instance ??= NetworkDioHandler._internal(ApiConstat.baseUrl);
    return _instance!;
  }

  NetworkDioHandler._internal(this.baseUrl) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        log("📩 Api Request : ${options.baseUrl}${options.path}");
        log("📦 Request Data: ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log("✅ Api Success Response : ${response.data}");
        return handler.next(response);
      },
      onError: (error, handler) {
        log("❌ Api Error Path    : ${error.requestOptions.path}");
        log("❌ Api Error Response: ${error.response?.data}");
        return handler.next(error);
      },
    ));
  }

  final String baseUrl;
  late Dio dio;

  String? currentUserId;
  String? currentRole;
  String? currentWorkStatus; // ← workStatus from login response

  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void setCurrentUser({
    required String userId,
    required String role,
    required String? workStatus,
  }) {
    currentUserId = userId;
    currentRole = role;
    currentWorkStatus = workStatus;
  }

  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
    currentUserId = null;
    currentRole = null;
    currentWorkStatus = "None";
  }
}