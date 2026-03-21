import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithMicrosoftUseCase {
  final AuthRepository _repository;

  SignUpWithMicrosoftUseCase(this._repository);

  Future<Either<Failure, AuthResponseEntity>> call({
    required String accessToken,
  }) {
    return _repository.signUpWithMicrosoft(accessToken: accessToken);
  }
}
