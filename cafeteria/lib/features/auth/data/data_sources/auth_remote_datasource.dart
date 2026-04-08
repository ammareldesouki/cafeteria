import 'package:cafeteria/core/constants/api.dart';
import 'package:dio/dio.dart';
import '../../../../core/failure/server_failure.dart';
import '../../../../core/network/dio_handler.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> signUpWithEmail({
    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
    required String name,
  });
  Future<AuthResponseModel> signIn({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> signUpWithGoogle({required String idToken});

  Future<AuthResponseModel> signUpWithMicrosoft({required String accessToken});

  Future<UserModel> getUserProfile();

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkDioHandler _dioHandler;

  AuthRemoteDataSourceImpl(this._dioHandler);

  @override
  Future<AuthResponseModel> signUpWithEmail({

    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
    required String name,
  }) async {
    try {
      final response = await _dioHandler.dio.post(
        EndPoints.signUp,
        data: {'email': email, 'password': password, 'phoneNumber': phoneNumber, 'gender': gender, 'name': name},
      );
      final model = AuthResponseModel.fromMap(response.data);

      // Persist auth token for subsequent requests
      _dioHandler.setAuthToken(model.token);
      _dioHandler.setCurrentUser(
        userId: model.user.id,
        role: model.user.role,
        workStatus: null,
      );
      return model;
    } on DioException catch (e) {
      throw ServerFailure.fromMap(
        (e.response?.data is Map<String, dynamic>)
            ? e.response!.data as Map<String, dynamic>
            : {'message': e.message ?? 'Unknown error'},
      );
    }
  }
  @override
  Future<AuthResponseModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioHandler.dio.post(
        EndPoints.signIn,
        data: {'email': email, 'password': password},
      );
      final model = AuthResponseModel.fromMap(response.data);

      // Persist auth token for subsequent requests
      _dioHandler.setAuthToken(model.token);
      _dioHandler.setCurrentUser(
        userId: model.user.id,
        role: model.user.role,
        workStatus: null,
      );
      return model;
    } on DioException catch (e) {
      throw ServerFailure.fromMap(
        (e.response?.data is Map<String, dynamic>)
            ? e.response!.data as Map<String, dynamic>
            : {'message': e.message ?? 'Unknown error'},
      );
    }
  }

  @override
  Future<AuthResponseModel> signUpWithGoogle({required String idToken}) async {
    try {
      final response = await _dioHandler.dio.post(
        '/api/v1/auth/sign-up/google',
        data: {'idToken': idToken},
      );
      final model = AuthResponseModel.fromMap(response.data);
      _dioHandler.setAuthToken(model.token);
      _dioHandler.setCurrentUser(
        userId: model.user.id,
        role: model.user.role,
        workStatus: null,
      );
      return model;
    } on DioException catch (e) {
      throw ServerFailure.fromMap(
        (e.response?.data is Map<String, dynamic>)
            ? e.response!.data as Map<String, dynamic>
            : {'message': e.message ?? 'Unknown error'},
      );
    }
  }

  @override
  Future<AuthResponseModel> signUpWithMicrosoft({
    required String accessToken,
  }) async {
    try {
      final response = await _dioHandler.dio.post(
        '/api/v1/auth/sign-up/microsoft',
        data: {'accessToken': accessToken},
      );
      final model = AuthResponseModel.fromMap(response.data);
      _dioHandler.setAuthToken(model.token);
      _dioHandler.setCurrentUser(
        userId: model.user.id,
        role: model.user.role,
        workStatus: null,
      );
      return model;
    } on DioException catch (e) {
      throw ServerFailure.fromMap(
        (e.response?.data is Map<String, dynamic>)
            ? e.response!.data as Map<String, dynamic>
            : {'message': e.message ?? 'Unknown error'},
      );
    }
  }
  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dioHandler.dio.get('/me');
      return UserModel.fromMap(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure.fromMap(
        (e.response?.data is Map<String, dynamic>)
            ? e.response!.data as Map<String, dynamic>
            : {'message': e.message ?? 'Unknown error'},
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dioHandler.dio.post('/api/v1/auth/sign-out');
      _dioHandler.clearAuthToken();
    } on DioException catch (e) {
      throw ServerFailure.fromMap(
        (e.response?.data is Map<String, dynamic>)
            ? e.response!.data as Map<String, dynamic>
            : {'message': e.message ?? 'Unknown error'},
      );
    }
  }
}
