part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignUpWithEmailEvent({required this.email, required this.password});

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

