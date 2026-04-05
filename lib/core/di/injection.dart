import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../../service/auth_api_service.dart';
import '../../service/user_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(secureStorage: getIt<FlutterSecureStorage>()),
  );

  
  getIt.registerLazySingleton<UserService>(
    () => UserService(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(dioClient: getIt<DioClient>()),
  );
}
