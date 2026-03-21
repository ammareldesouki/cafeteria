import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<void> cacheUser(UserModel user);
  Future<String?> getCachedToken();
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await _prefs.setString(_userKey, json.encode(user.toMap()));
  }

  @override
  Future<String?> getCachedToken() async {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return UserModel.fromMap(json.decode(raw));
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
