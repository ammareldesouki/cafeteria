import 'dart:io';

class ApiConstat {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:3001/api/v1"; // Android Emulator host IP
    }
    return "http://localhost:3001/api/v1"; // iOS Simulator / Web
  }
}

class EndPoints {
  static const String signIn = "/auth/sign-in/email";
  // static const String offers = 'api/offers';
  // static const String profile = '/api/profile';
  // static const String logout = '/api/auth/logout';

  //  ------------Psw EndPoind----------------
  static const String signUp = "/auth/sign-up/email";
  static const String googleSignIn = "/auth/sign-in/social";





}