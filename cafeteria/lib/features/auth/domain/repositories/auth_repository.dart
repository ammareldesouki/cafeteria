import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../entities/auth_response_entity.dart';

abstract class AuthRepository {
  /// Sign up with email and password.
  Future<Either<Failure, AuthResponseEntity>> signUpWithEmail({
    required String email,
    required String password,
  });


  Future<Either<Failure, AuthResponseEntity>> signIn({
    required String email,
    required String password,
  });


  /// Sign up / sign in with Google OAuth.
  /// [idToken] is obtained from google_sign_in package.
  Future<Either<Failure, AuthResponseEntity>> signUpWithGoogle({
    required String idToken,
  });

  /// Sign up / sign in with Microsoft (Outlook) OAuth.
  /// [accessToken] is obtained from aad_oauth package.
  Future<Either<Failure, AuthResponseEntity>> signUpWithMicrosoft({
    required String accessToken,
  });
}
