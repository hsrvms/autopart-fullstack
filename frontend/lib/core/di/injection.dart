import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/vehicles/data/repositories/make_repository.dart';
import '../../features/vehicles/data/repositories/model_repository.dart';
import '../../features/vehicles/data/repositories/submodel_repository.dart';
import '../../features/inventory/data/repositories/part_repository.dart';
import '../../features/inventory/data/repositories/category_repository.dart';
import '../config/app_config.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
    receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
    validateStatus: (status) {
      return status! < 500;
    },
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  // Interceptors
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print('\n*** Request ***');
      print('uri: ${options.uri}');
      print('method: ${options.method}');
      print('headers: ${options.headers}');
      print('data: ${options.data}');
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('\n*** Response ***');
      print('uri: ${response.requestOptions.uri}');
      print('statusCode: ${response.statusCode}');
      print('data: ${response.data}');
      return handler.next(response);
    },
    onError: (error, handler) {
      print('\n*** Error ***');
      print('uri: ${error.requestOptions.uri}');
      print('statusCode: ${error.response?.statusCode}');
      print('error: ${error.message}');
      print('response: ${error.response?.data}');
      return handler.next(error);
    },
  ));

  getIt.registerLazySingleton<Dio>(() => dio);

  // Repositories
  getIt.registerLazySingleton<MakeRepository>(() => MakeRepository(getIt<Dio>()));
  getIt.registerLazySingleton<ModelRepository>(() => ModelRepository());
  getIt.registerLazySingleton<SubModelRepository>(() => SubModelRepository());
  getIt.registerLazySingleton<PartRepository>(() => PartRepository(getIt<Dio>()));
  getIt.registerLazySingleton<CategoryRepository>(() => CategoryRepository());
}
