import 'package:digital_library/service/categorie_service.dart';
import 'package:digital_library/service/commande_service.dart';
import 'package:digital_library/service/livre_service.dart';
import 'package:digital_library/service/recommendation_service.dart';
import 'package:digital_library/service/avis_service.dart';
import 'package:digital_library/service/stats_service.dart';
import 'package:digital_library/service/paiement_service.dart';
import 'package:digital_library/service/lecture_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../../service/auth_api_service.dart';
import '../../service/user_service.dart';
import '../../service/auth_service.dart';

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
  getIt.registerLazySingleton<LivreService>(
    () => LivreService(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<CategorieService>(
    () => CategorieService(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<StatsService>(
    () => StatsService(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<RecommendationService>(
    () => RecommendationService(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AvisService>(
    () => AvisService(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<CommandeService>(
    () => CommandeService(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<PaiementService>(
    () => PaiementService(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<LectureService>(
    () => LectureService(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      apiService: getIt<AuthApiService>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );
}
