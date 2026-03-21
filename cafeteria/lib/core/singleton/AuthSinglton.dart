//
// import 'package:carehome/features/auth/data/data_sources/auth_remote_datasource.dart';
//
// import '../network/dio_handler.dart';
//
// abstract class AuthDi {
//   // Dio
//   // Data Source
//   // Repository
//   // Use Cases
//   // Bloc
//   static Future<void> setUp() async {
//     sl..registerLazySingleton(() => NetworkDioHandler(ApiConstat.AuthbaseUrl))
//       ..registerLazySingleton<AuthRemoteDataSource>(
//             () => AuthRemoteDataSourceImpl(sl.get<NetworkDioHandler>()),
//       )
//       ..registerLazySingleton<AuthRepositoriseInterface>(
//             () => AuthRepositoryImp(sl.get<AuthDataSourceInterface>()),
//       )
//       ..registerLazySingleton(
//             () => SignInUseCase(sl.get<AuthRepositoriseInterface>()),
//       )
//       ..registerLazySingleton(
//             () => SignUpUseCase(sl.get<AuthRepositoriseInterface>()),
//       )..registerLazySingleton<AuthBloc>(() =>
//         AuthBloc())..registerLazySingleton(() =>
//         GetProfileUseCase(sl.get<AuthRepositoriseInterface>()))
//     ;
//     // ..registerLazySingleton(()=>ForgetPasswordUseCase(sl.get<AuthRepositoriseInterface>()));
//   }
// }
