part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String phoneNumber;
  final String gender;
  final String name;


  const SignUpWithEmailEvent({required this.email, required this.password, required this.phoneNumber, required this.gender, required this.name});

  @override
  List<Object?> get props => [email, password];


}
class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];


}

class SignUpWithGoogleEvent extends AuthEvent {
  const SignUpWithGoogleEvent();
}

class SignUpWithMicrosoftEvent extends AuthEvent {
  const SignUpWithMicrosoftEvent();
}

class GetUserInfoEvent extends AuthEvent {
  const GetUserInfoEvent();
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class ForgetPasswordEvent extends AuthEvent {
  final String email;

  const ForgetPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String newPassword;
  final String token;

  const ResetPasswordEvent({required this.newPassword, required this.token});

  @override
  List<Object?> get props => [newPassword, token];
}

