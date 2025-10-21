import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../../data/repositories/auth_repository.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Core - Register Dependencies
  getIt.registerLazySingleton(() => ApiClient());
  getIt.registerLazySingleton(() => FlutterSecureStorage());
  
  // Repositories - AuthRepository membutuhkan 2 parameter: ApiClient & FlutterSecureStorage
  getIt.registerLazySingleton(() => AuthRepository(
    getIt<ApiClient>(),              // Parameter 1: ApiClient
    getIt<FlutterSecureStorage>(),   // Parameter 2: FlutterSecureStorage
  ));
}  