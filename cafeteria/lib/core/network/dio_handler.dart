import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api.dart';

class NetworkDioHandler {
  static NetworkDioHandler? _instance;
  late final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'user_role';

  factory NetworkDioHandler() {
    return _instance!;
  }

  static Future<void> init(SharedPreferences prefs) async {
    _instance = NetworkDioHandler._internal(ApiConstat.baseUrl, prefs);
    await _instance!._loadFromPrefs();
  }

  NetworkDioHandler._internal(this.baseUrl, this._prefs) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
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
  String? currentWorkStatus;

  Future<void> _loadFromPrefs() async {
    final token = _prefs.getString(_tokenKey);
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    currentUserId = _prefs.getString(_userIdKey);
    currentRole = _prefs.getString(_roleKey);
  }

  Future<void> setAuthToken(String token) async {
    dio.options.headers['Authorization'] = 'Bearer $token';
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> setCurrentUser({
    required String userId,
    required String role,
    required String? workStatus,
  }) async {
    currentUserId = userId;
    currentRole = role;
    currentWorkStatus = workStatus;
    await _prefs.setString(_userIdKey, userId);
    await _prefs.setString(_roleKey, role);
  }

  Future<void> clearAuthToken() async {
    dio.options.headers.remove('Authorization');
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_roleKey);
    currentUserId = null;
    currentRole = null;
    currentWorkStatus = "None";
  }

  bool hasToken() => _prefs.containsKey(_tokenKey);
}