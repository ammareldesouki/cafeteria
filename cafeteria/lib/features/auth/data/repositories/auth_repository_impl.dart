import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../../../../core/failure/server_failure.dart';
import '../../domain/entities/auth_response_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_local_datasource.dart';
import '../data_sources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  Future<void> _persistSession(AuthResponseEntity response) async {
    await _local.cacheToken(response.token);
    await _local.cacheUser(response.user as UserModel);
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> signUpWithEmail({

    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
    required String name,
  }) async {
    try {
      final result = await _remote.signUpWithEmail(
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        gender: gender,
        name: name,
      );
      await _persistSession(result);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }


  @override
  Future<Either<Failure, AuthResponseEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remote.signIn(
        email: email,
        password: password,
      );
      await _persistSession(result);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }


  @override
  Future<Either<Failure, AuthResponseEntity>> signUpWithGoogle({
    required String idToken,
  }) async {
    try {
      final result = await _remote.signUpWithGoogle(idToken: idToken);
      await _persistSession(result);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> signUpWithMicrosoft({
    required String accessToken,
  }) async {
    try {
      final result =
          await _remote.signUpWithMicrosoft(accessToken: accessToken);
      await _persistSession(result);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    try {
      final result = await _remote.getUserProfile();
      await _local.cacheUser(result);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      await _local.clearCache();

      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgetPassword({required String email}) async {
    try {
      await _remote.forgetPassword(email: email);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String newPassword,
    required String token,
  }) async {
    try {
      await _remote.resetPassword(newPassword: newPassword, token: token);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
