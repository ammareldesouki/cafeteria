import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithGoogleUseCase {
  final AuthRepository _repository;

  SignUpWithGoogleUseCase(this._repository);

  Future<Either<Failure, AuthResponseEntity>> call({
    required String idToken,
  }) {
    return _repository.signUpWithGoogle(idToken: idToken);
  }
}
