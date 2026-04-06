import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool emailVerified;
  final String role;
  final String createdAt;
  final String updatedAt;
  final String phoneNumber;
  final String gender;


  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerified,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.phoneNumber,
    required this.gender,
  });

  @override
  List<Object?> get props => [id, email, role];
}
