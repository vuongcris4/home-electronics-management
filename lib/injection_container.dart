// lib/injection_container.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/auth_interceptor.dart';
import 'core/navigation/navigation_service.dart';

// --- Domain ---
import 'domain/repositories.dart';
import 'domain/usecases/auth_usecases.dart';
import 'domain/usecases/device_usecases.dart';
import 'domain/usecases/room_usecases.dart';

// --- Infrastructure ---
import 'infrastructure/auth/auth_data_sources.dart';
import 'infrastructure/auth/auth_repository_impl.dart';
import 'infrastructure/device/device_data_source.dart';
import 'infrastructure/device/device_repository_impl.dart';
import 'infrastructure/room/room_data_source.dart';
import 'infrastructure/room/room_repository_impl.dart';


// --- Presentation (Providers) ---
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/home_provider.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // -------------------- Presentation --------------------
  getIt.registerFactory<AuthProvider>(
    () => AuthProvider(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      getUserProfileUseCase: getIt<GetUserProfileUseCase>(),
      updateUserProfileUseCase: getIt<UpdateUserProfileUseCase>(),
    ),
  );

  getIt.registerFactory<HomeProvider>(
    () => HomeProvider(
      getRoomsUseCase: getIt<GetRoomsUseCase>(),
      addRoomUseCase: getIt<AddRoomUseCase>(),
      deleteRoomUseCase: getIt<DeleteRoomUseCase>(),
      updateRoomUseCase: getIt<UpdateRoomUseCase>(),
      addDeviceUseCase: getIt<AddDeviceUseCase>(),
      deleteDeviceUseCase: getIt<DeleteDeviceUseCase>(),
      updateDeviceUseCase: getIt<UpdateDeviceUseCase>(),
      storage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // -------------------- Domain (Use Cases) --------------------
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetUserProfileUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => UpdateUserProfileUseCase(getIt<AuthRepository>()));

  getIt.registerLazySingleton(() => GetRoomsUseCase(getIt<RoomRepository>()));
  getIt.registerLazySingleton(() => AddRoomUseCase(getIt<RoomRepository>()));
  getIt.registerLazySingleton(() => DeleteRoomUseCase(getIt<RoomRepository>()));
  getIt.registerLazySingleton(() => UpdateRoomUseCase(getIt<RoomRepository>()));

  getIt.registerLazySingleton(() => AddDeviceUseCase(getIt<DeviceRepository>()));
  getIt.registerLazySingleton(() => DeleteDeviceUseCase(getIt<DeviceRepository>()));
  getIt.registerLazySingleton(() => UpdateDeviceUseCase(getIt<DeviceRepository>()));

  // -------------------- Infrastructure (Repositories) --------------------
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<RoomRepository>(
    () => RoomRepositoryImpl(remote: getIt<RoomRemoteDataSource>()),
  );
  getIt.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(remote: getIt<DeviceRemoteDataSource>()),
  );

  // -------------------- Infrastructure (Data Sources) --------------------
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<RoomRemoteDataSource>(
    () => RoomRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // -------------------- Core / External --------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  getIt.registerLazySingleton<NavigationService>(() => NavigationService());

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: "https://mrh3.dongnama.app/api",
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    ));
    dio.interceptors.add(AuthInterceptor(dio));
    return dio;
  });

  getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
}