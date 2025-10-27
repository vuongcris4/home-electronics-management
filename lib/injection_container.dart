// lib/injection_container.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- THÊM MỚI

import 'core/api/auth_interceptor.dart';
import 'core/navigation/navigation_service.dart';

// -------------------- Auth (Domain & Infra) --------------------
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/get_user_profile_usecase.dart';
import 'infrastructure/datasources/auth_local_data_source.dart';
import 'infrastructure/datasources/auth_remote_data_source.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';

// -------------------- Room (Domain & Infra) --------------------
import 'domain/repositories/room_repository.dart';
import 'domain/usecases/get_rooms_usecase.dart';
import 'domain/usecases/add_room_usecase.dart';
import 'domain/usecases/delete_room_usecase.dart';
import 'infrastructure/datasources/room_remote_data_source.dart';
import 'infrastructure/repositories/room_repository_impl.dart';

// -------------------- Device (Domain & Infra) --------------------
import 'domain/repositories/device_repository.dart';
import 'domain/usecases/add_device_usecase.dart';
import 'domain/usecases/delete_device_usecase.dart';
import 'infrastructure/datasources/device_remote_data_source.dart';
import 'infrastructure/repositories/device_repository_impl.dart';

// -------------------- Presentation (Providers) --------------------
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
    ),
  );

  getIt.registerFactory<HomeProvider>(
    () => HomeProvider(
      getRoomsUseCase: getIt<GetRoomsUseCase>(),
      addRoomUseCase: getIt<AddRoomUseCase>(),
      deleteRoomUseCase: getIt<DeleteRoomUseCase>(),
      addDeviceUseCase: getIt<AddDeviceUseCase>(),
      deleteDeviceUseCase: getIt<DeleteDeviceUseCase>(),
      storage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(), // <-- CẬP NHẬT
    ),
  );

  // -------------------- Domain (Use Cases) --------------------
  getIt.registerLazySingleton(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => GetUserProfileUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetRoomsUseCase(getIt<RoomRepository>()));
  getIt.registerLazySingleton(() => AddRoomUseCase(getIt<RoomRepository>()));
  getIt.registerLazySingleton(() => DeleteRoomUseCase(getIt<RoomRepository>()));
  getIt
      .registerLazySingleton(() => AddDeviceUseCase(getIt<DeviceRepository>()));
  getIt.registerLazySingleton(
      () => DeleteDeviceUseCase(getIt<DeviceRepository>()));

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
  // <-- THÊM MỚI: Khởi tạo và đăng ký SharedPreferences
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
