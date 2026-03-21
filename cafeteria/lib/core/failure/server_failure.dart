import 'dart:convert';
import 'failure.dart';

class ServerFailure extends Failure {
  String? error;
  String? errorCode;
  String? message;

  ServerFailure({
    this.error,
    this.errorCode,
    this.message,
    String? statusCode,
    String? messageAr,
    String? messageEn,
  }) : super(
          statusCode: statusCode,
          messageAr: messageAr,
          messageEn: messageEn,
        );

  factory ServerFailure.fromMap(Map<String, dynamic> map) {
    return ServerFailure(
      statusCode: map['statusCode']?.toString(),
      messageAr: map['messageAr'],
      messageEn: map['messageEn'],
      error: map['error'],
      errorCode: map['errorCode'],
      message: map['message'],
    );
  }

  factory ServerFailure.fromJson(String source) =>
      ServerFailure.fromMap(json.decode(source));
}
