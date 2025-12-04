// lib/injection_container.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_config.dart'; // Import file config
import 'core/api/auth_interceptor.dart';
import 'core/navigation/navigation_service.dart';

// --- Domain ---
import 'domain/repositories.dart';

// --- Infrastructure (Repositories Implementation) ---
import 'infrastructure/auth/auth_repository_impl.dart';
import 'infrastructure/device/device_repository_impl.dart';
import 'infrastructure/room/room_repository_impl.dart';

// --- Presentation (Providers) ---
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/home_provider.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // -------------------- Presentation --------------------
  getIt.registerFactory<AuthProvider>(
    () => AuthProvider(
      authRepository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerFactory<HomeProvider>(
    () => HomeProvider(
      roomRepository: getIt<RoomRepository>(),
      deviceRepository: getIt<DeviceRepository>(),
      storage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // -------------------- Domain / Infrastructure (Repositories) --------------------
  // Update: Inject Dio và Storage trực tiếp vào Repository Impl
  
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dio: getIt<Dio>(),
      storage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<RoomRepository>(
    () => RoomRepositoryImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(dio: getIt<Dio>()),
  );

  // -------------------- Core / External --------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  getIt.registerLazySingleton<NavigationService>(() => NavigationService());

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    ));
    dio.interceptors.add(AuthInterceptor(dio));
    return dio;
  });

  getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
}