import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String newPassword,
    required String token,
  }) {
    return _repository.resetPassword(newPassword: newPassword, token: token);
  }
}
