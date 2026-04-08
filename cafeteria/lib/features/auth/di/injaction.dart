import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_handler.dart';
import '../../cart/data/data_sources/cart_remote_datasource.dart';
import '../../cart/data/repositories/cart_repository_impl.dart';
import '../../cart/domain/repositories/cart_repository.dart';
import '../../cart/domain/use_cases/cart_usecases.dart';
import '../../favourite/data/data_sources/favourite_remote_datasource.dart';
import '../../favourite/data/repositories/favourite_repository_impl.dart' hide FavouriteRemoteDataSourceImpl;
import '../../favourite/domain/repositories/favourite_repository.dart';
import '../../favourite/domain/use_cases/add_favourite_usecase.dart';
import '../../favourite/domain/use_cases/get_favourites_usecase.dart';
import '../../favourite/domain/use_cases/remove_favourite_usecase.dart';
import '../../favourite/presentation/manager/favourite_bloc.dart';
import '../../home/data/data_sources/home_remote_datasource.dart';
import '../../home/data/repositories/home_repository_impl.dart';
import '../../home/domain/repositories/home_repository.dart';
import '../../home/domain/use_cases/get_menu_items_usecase.dart';
import '../../home/presentation/manager/home_bloc.dart';
import '../data/data_sources/auth_local_datasource.dart';
import '../data/data_sources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/use_cases/get_user_profile_usecase.dart';
import '../domain/use_cases/sign_in_with_email_usesace.dart';
import '../domain/use_cases/sign_out_usecase.dart';
import '../domain/use_cases/sign_up_with_email_usecase.dart';
import '../domain/use_cases/sign_up_with_google_usecase.dart';
import '../domain/use_cases/sign_up_with_microsoft_usecase.dart';
import '../presentation/manager/auth_bloc.dart';
import '../../cart/presentation/manager/cart_bloc.dart';
import '../../order/data/data_sources/order_remote_datasource.dart';
import '../../order/data/repositories/order_repository_impl.dart';
import '../../order/domain/repositories/order_repository.dart';
import '../../order/domain/use_cases/order_usecases.dart';
import '../../order/presentation/manager/order_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  /// ── External ─────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  /// ── Core ────────────────────────────────
  sl.registerLazySingleton<NetworkDioHandler>(() => NetworkDioHandler());

  /// ── Auth DataSources ────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(sl()),
  );

  /// ── Auth Repo ───────────────────────────
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl(), sl()),
  );

  /// ── Auth UseCases ───────────────────────
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithMicrosoftUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  /// ── Cart DataSource ─────────────────────
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(sl()),
  );

  /// ── Cart Repo ───────────────────────────
  sl.registerLazySingleton<CartRepository>(
        () => CartRepositoryImpl(sl()),
  );

  /// ── Favourite DataSource ────────────────
  sl.registerLazySingleton<FavouriteRemoteDataSource>(
        () => FavouriteRemoteDataSourceImpl(sl()),
  );

  /// ── Favourite Repo ──────────────────────
  sl.registerLazySingleton<FavouriteRepository>(
        () => FavouriteRepositoryImpl(sl()),
  );

  /// ── Favourite UseCases ──────────────────
  sl.registerLazySingleton(() => GetFavouritesUseCase(sl()));
  sl.registerLazySingleton(() => AddFavouriteUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFavouriteUseCase(sl()));

  /// ── Favourite Bloc ──────────────────────
  sl.registerLazySingleton(
        () => FavouriteBloc(
      getFavouritesUseCase: sl(),
      addFavouriteUseCase: sl(),
      removeFavouriteUseCase: sl(),
    ),
  );

  /// ── Home DataSource ─────────────────────
  sl.registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(sl()),
  );

  /// ── Home Repo ───────────────────────────
  sl.registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(sl()),
  );

  /// ── Home UseCase ────────────────────────
  sl.registerLazySingleton(() => GetMenuItemsUseCase(sl()));

  /// ── Home Bloc ───────────────────────────
  sl.registerLazySingleton(() => HomeBloc(sl()));

  /// ── Auth Bloc ───────────────────────────
  sl.registerFactory(
        () => AuthBloc(
      signIn: sl(),
      signUpWithEmail: sl(),
      signUpWithGoogle: sl(),
      signUpWithMicrosoft: sl(),
      getUserProfile: sl(),
      signOut: sl(),
    ),
  );

  /// ── Cart UseCases ───────────────────────
  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddCartItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartItemUseCase(sl()));
  sl.registerLazySingleton(() => RemoveCartItemUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));

  /// ── Cart Bloc ───────────────────────────
  sl.registerLazySingleton(() => CartBloc(
    getCartUseCase: sl(),
    addCartItemUseCase: sl(),
    updateCartItemUseCase: sl(),
    removeCartItemUseCase: sl(),
    clearCartUseCase: sl(),
  ));

  /// ── Order DataSource ────────────────────
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl()),
  );

  /// ── Order Repo ──────────────────────────
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl()),
  );

  /// ── Order UseCases ──────────────────────
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderByIdUseCase(sl()));
  sl.registerLazySingleton(() => CancelOrderUseCase(sl()));

  /// ── Order Bloc ──────────────────────────
  sl.registerLazySingleton(() => OrderBloc(
    createOrderUseCase: sl(),
    getOrdersUseCase: sl(),
    getOrderByIdUseCase: sl(),
    cancelOrderUseCase: sl(),
  ));
}