import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../repositories/auth_repository.dart';

class ForgetPasswordUseCase {
  final AuthRepository _repository;

  ForgetPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call({required String email}) {
    return _repository.forgetPassword(email: email);
  }
}
