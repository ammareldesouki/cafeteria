import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetUserProfileUseCase {
  final AuthRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await _repository.getUserProfile();
  }
}
