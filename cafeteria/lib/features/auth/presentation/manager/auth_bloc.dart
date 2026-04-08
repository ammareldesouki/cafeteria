import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';


import '../../domain/entities/auth_response_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/use_cases/get_user_profile_usecase.dart';
import '../../domain/use_cases/sign_in_with_email_usesace.dart';
import '../../domain/use_cases/sign_out_usecase.dart';
import '../../domain/use_cases/sign_up_with_email_usecase.dart';
import '../../domain/use_cases/sign_up_with_google_usecase.dart';
import '../../domain/use_cases/sign_up_with_microsoft_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpWithEmailUseCase _signUpWithEmail;
  final SignUpWithGoogleUseCase _signUpWithGoogle;
  final SignUpWithMicrosoftUseCase _signUpWithMicrosoft;
  final SignInUseCase _signIn;
  final GetUserProfileUseCase _getUserProfile;
  final SignOutUseCase _signOut;



  // ── Google Sign-In ──────────────────────────────────────────────────────
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // ── Microsoft / Outlook OAuth ───────────────────────────────────────────
  // Replace with your Azure AD tenant ID and client ID.
  // static final Config _msalConfig = Config(
  //
  //   tenant: 'YOUR_TENANT_ID',        // e.g. 'common' for multi-tenant
  //   clientId: 'YOUR_CLIENT_ID',
  //   scope: 'openid profile email offline_access',
  //   redirectUri: 'msauth://YOUR_PACKAGE_NAME/callback',
  //   isB2C: false,
  // );
  // final AadOAuth _aadOAuth = AadOAuth(_msalConfig);

  AuthBloc( {
    required SignUpWithEmailUseCase signUpWithEmail,
    required SignUpWithGoogleUseCase signUpWithGoogle,
    required SignUpWithMicrosoftUseCase signUpWithMicrosoft,
    required SignInUseCase signIn,
    required GetUserProfileUseCase getUserProfile,
    required SignOutUseCase signOut,
  })  : _signUpWithEmail = signUpWithEmail,
        _signUpWithGoogle = signUpWithGoogle,
        _signUpWithMicrosoft = signUpWithMicrosoft,
        _signIn = signIn,
        _getUserProfile = getUserProfile,
        _signOut = signOut,
        super(AuthInitial()) {
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInEvent>(_onSsignIn);
    on<GetUserInfoEvent>(_onGetUserInfo);
    on<SignOutEvent>(_onSignOut);
    // on<SignUpWithGoogleEvent>(_onSignUpWithGoogle);
    // on<SignUpWithMicrosoftEvent>(_onSignUpWithMicrosoft);
  }

  // ── Email Sign-Up ────────────────────────────────────────────────────────
  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _signUpWithEmail(
      email: event.email,
      password: event.password,
      phoneNumber: event.phoneNumber,
      gender: event.gender,
      name: event.name,
    );
    result.fold(
      (failure) => emit(AuthFailureState(
        failure.messageEn ?? failure.messageAr ?? 'Sign up failed',
      )),
      (response) => emit(AuthSuccess(response)),
    );
  }
  Future<void> _onSsignIn(
      SignInEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final result = await _signIn(
      email: event.email,
      password: event.password,
    );
    result.fold(
          (failure) => emit(AuthFailureState(
        failure.messageEn ?? failure.messageAr ?? 'Sign up failed',
      )),
          (response) => emit(AuthSuccess(response)),
    );
  }

  Future<void> _onGetUserInfo(
    GetUserInfoEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _getUserProfile();
    result.fold(
      (failure) => emit(AuthFailureState(
        failure.messageEn ?? failure.messageAr ?? 'Failed to fetch profile',
      )),
      (user) => emit(UserProfileLoaded(user)),
    );
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _signOut();
    result.fold(
      (failure) => emit(AuthFailureState(
        failure.messageEn ?? failure.messageAr ?? 'Logout failed',
      )),
      (_) => emit(UserSignedOut()),
    );
  }

  // ── Google Sign-Up ───────────────────────────────────────────────────────
  // Future<void> _onSignUpWithGoogle(
  //   SignUpWithGoogleEvent event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   try {
  //     // 1. Trigger Google OAuth flow
  //     final googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       emit(const AuthFailureState('Google sign-in was cancelled'));
  //       return;
  //     }
  //
  //     // 2. Get authentication tokens
  //     final googleAuth = await googleUser.authentication;
  //     final idToken = googleAuth.idToken;
  //
  //     if (idToken == null) {
  //       emit(const AuthFailureState('Could not retrieve Google ID token'));
  //       return;
  //     }
  //
  //     // 3. Send idToken to your backend
  //     final result = await _signUpWithGoogle(idToken: idToken);
  //     result.fold(
  //       (failure) => emit(AuthFailureState(
  //         failure.messageEn ?? failure.messageAr ?? 'Google sign-up failed',
  //       )),
  //       (response) => emit(AuthSuccess(response)),
  //     );
  //   } catch (e) {
  //     emit(AuthFailureState(e.toString()));
  //   }
  // }

  // // ── Microsoft / Outlook Sign-Up ──────────────────────────────────────────
  // Future<void> _onSignUpWithMicrosoft(
  //   SignUpWithMicrosoftEvent event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   try {
  //     // 1. Trigger Microsoft OAuth flow
  //     await _aadOAuth.login();
  //     final accessToken = await _aadOAuth.getAccessToken();
  //
  //     if (accessToken == null) {
  //       emit(const AuthFailureState('Could not retrieve Microsoft access token'));
  //       return;
  //     }
  //
  //     // 2. Send accessToken to your backend
  //     final result = await _signUpWithMicrosoft(accessToken: accessToken);
  //     result.fold(
  //       (failure) => emit(AuthFailureState(
  //         failure.messageEn ?? failure.messageAr ?? 'Microsoft sign-up failed',
  //       )),
  //       (response) => emit(AuthSuccess(response)),
  //     );
  //   } catch (e) {
  //     emit(AuthFailureState(e.toString()));
  //   }
  // }
}
