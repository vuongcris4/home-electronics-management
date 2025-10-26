// lib/injection_container.dart
// dùng plantuml.com để vẽ flow
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'core/api/auth_interceptor.dart';
import 'core/navigation/navigation_service.dart';

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

//Nhiệm vụ chính của get_it là: quản lý và cung cấp instance của các service (hoặc class) đã được đăng ký từ bên ngoài,
// để bạn có thể lấy ra inject vào Provider mà không phải khởi tạo thủ công từng nơi.

// Service Locator, đối tượng trung tâm quản lí các dependency (phụ thuộc) trong ứng dụng
// Nghĩa là bạn có một singleton toàn cục, nơi bạn “đăng ký” và “lấy ra” các đối tượng cần dùng.

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // -------------------- Presentation --------------------
  getIt.registerFactory<AuthProvider>(
    () => AuthProvider(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
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
    ),
  );

  // -------------------- Domain (Use Cases) --------------------
  getIt.registerLazySingleton(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
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
  // Sửa các DataSource để dùng Dio
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: getIt<Dio>()), // SỬA Ở ĐÂY
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<RoomRemoteDataSource>(
    () => RoomRemoteDataSourceImpl(dio: getIt<Dio>()), // SỬA Ở ĐÂY
  );
  getIt.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(dio: getIt<Dio>()), // SỬA Ở ĐÂY
  );

  // -------------------- Core / External --------------------
  // Đăng ký NavigationService
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());

  // Thay http.Client bằng Dio và thêm Interceptor
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: "https://mrh3.dongnama.app/api",
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    ));
    // Thêm interceptor vào Dio instance
    dio.interceptors.add(AuthInterceptor(dio));
    return dio;
  });

  getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
}
