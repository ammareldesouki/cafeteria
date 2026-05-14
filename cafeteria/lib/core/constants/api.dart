import 'dart:io';

class ApiConstat {
  static String get baseUrl {
    return "https://cafeteria-production-85c5.up.railway.app/api/v1";
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