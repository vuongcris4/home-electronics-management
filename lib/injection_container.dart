// lib/injection_container.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// Auth Imports
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'infrastructure/datasources/auth_local_data_source.dart';
import 'infrastructure/datasources/auth_remote_data_source.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';

// Device & Room Imports
import 'domain/repositories/device_repository.dart';
import 'domain/usecases/add_device_usecase.dart';
import 'domain/usecases/add_room_usecase.dart';
import 'domain/usecases/delete_device_usecase.dart';
import 'domain/usecases/delete_room_usecase.dart';
import 'domain/usecases/get_rooms_usecase.dart';
import 'infrastructure/datasources/device_remote_data_source.dart';
import 'infrastructure/repositories/device_repository_impl.dart';
import 'presentation/providers/home_provider.dart';

// Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // --- Presentation (Providers) ---
  sl.registerFactory(
    () => AuthProvider(
      loginUseCase: sl(),
      registerUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => HomeProvider(
      getRoomsUseCase: sl(),
      addRoomUseCase: sl(),
      deleteRoomUseCase: sl(),
      addDeviceUseCase: sl(),
      deleteDeviceUseCase: sl(),
      storage: sl(), // <-- THÊM DÒNG NÀY
    ),
  );

  // --- Domain (Use Cases) ---
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetRoomsUseCase(sl()));
  sl.registerLazySingleton(() => AddRoomUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRoomUseCase(sl()));
  sl.registerLazySingleton(() => AddDeviceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDeviceUseCase(sl()));

  // --- Infrastructure (Repositories) ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Infrastructure (Data Sources) ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(client: sl(), storage: sl()),
  );

  // --- External ---
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}