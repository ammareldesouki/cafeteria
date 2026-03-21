import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_handler.dart';
import '../../home/data/data_sources/home_remote_datasource.dart';
import '../../home/data/repositories/home_repository_impl.dart';
import '../../home/domain/repositories/home_repository.dart';
import '../../home/domain/use_cases/get_menu_items_usecase.dart';
import '../../home/presentation/manager/home_bloc.dart';
import '../data/data_sources/auth_local_datasource.dart';
import '../data/data_sources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/use_cases/sign_in_with_email_usesace.dart';
import '../domain/use_cases/sign_up_with_email_usecase.dart';
import '../domain/use_cases/sign_up_with_google_usecase.dart';
import '../domain/use_cases/sign_up_with_microsoft_usecase.dart';
import '../presentation/manager/auth_bloc.dart';


final sl = GetIt.instance;

/// Call once from main() — must be awaited before runApp().
Future<void> setupLocator() async {
  // ── External ─────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // ── Core ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkDioHandler>(() => NetworkDioHandler());

  // ── Data Sources ──────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(sl()),
  );

  // ── Repositories ──────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl(), sl()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithMicrosoftUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));



 sl.registerLazySingleton<HomeRemoteDataSource>(
     () => HomeRemoteDataSourceImpl(sl()));
 sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
 sl.registerLazySingleton(() => GetMenuItemsUseCase(sl()));
 sl.registerLazySingleton(() => HomeBloc(sl()));   // singleton — fetches once


  // ── BLoC ──────────────────────────────────────────────────────────────
  sl.registerFactory(
        () => AuthBloc(
          signIn: sl(),
      signUpWithEmail: sl(),
      signUpWithGoogle: sl(),
      signUpWithMicrosoft: sl(),
    ),
  );
}
