import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailUseCase {
  final AuthRepository _repository;

  SignUpWithEmailUseCase(this._repository);

  Future<Either<Failure, AuthResponseEntity>> call({
    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
  }) {
    return _repository.signUpWithEmail(email: email, password: password, phoneNumber: phoneNumber, gender: gender);
  }
}
