// lib/injection_container.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// -------------------- Auth (Domain & Infra) --------------------
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/register_usecase.dart';
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

// Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // -------------------- Presentation --------------------
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
      storage: sl(), // FlutterSecureStorage
    ),
  );

  // -------------------- Domain (Use Cases) --------------------
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));

  // Rooms -> dùng RoomRepository
  sl.registerLazySingleton(() => GetRoomsUseCase(sl<RoomRepository>()));
  sl.registerLazySingleton(() => AddRoomUseCase(sl<RoomRepository>()));
  sl.registerLazySingleton(() => DeleteRoomUseCase(sl<RoomRepository>()));

  // Devices -> dùng DeviceRepository
  sl.registerLazySingleton(() => AddDeviceUseCase(sl<DeviceRepository>()));
  sl.registerLazySingleton(() => DeleteDeviceUseCase(sl<DeviceRepository>()));

  // -------------------- Infrastructure (Repositories) --------------------
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<RoomRepository>(
    () => RoomRepositoryImpl(remote: sl()),
  );

  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(remote: sl()),
  );

  // -------------------- Infrastructure (Data Sources) --------------------
  // Auth Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl()),
  );

  // Room Data Source
  sl.registerLazySingleton<RoomRemoteDataSource>(
    () => RoomRemoteDataSourceImpl(client: sl(), storage: sl()),
  );

  // Device Data Source
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(client: sl(), storage: sl()),
  );

  // -------------------- External --------------------
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
}
