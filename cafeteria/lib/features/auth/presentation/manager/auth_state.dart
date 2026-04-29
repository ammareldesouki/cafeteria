part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthResponseEntity response;

  const AuthSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
class UserProfileLoaded extends AuthState {
  final UserEntity user;

  const UserProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserSignedOut extends AuthState {}

class ForgetPasswordSuccess extends AuthState {
  final String message;

  const ForgetPasswordSuccess({this.message = 'Reset token sent successfully. Please check your email.'});

  @override
  List<Object?> get props => [message];
}

class ResetPasswordSuccess extends AuthState {
  final String message;

  const ResetPasswordSuccess({this.message = 'Password has been reset successfully. You can now log in.'});

  @override
  List<Object?> get props => [message];
}
