import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://57.129.47.116:8080/api',
  );

  // API endpoint'leri
  static String get makesEndpoint => '$baseUrl/makes';
  static String get modelsEndpoint => '$baseUrl/models';
  static String get submodelsEndpoint => '$baseUrl/submodels';
  static String get categoriesEndpoint => '$baseUrl/categories';
  static String get suppliersEndpoint => '$baseUrl/suppliers';
  static String get itemsEndpoint => '$baseUrl/items';
  static String get searchEndpoint => '$baseUrl/items/search';

  static const int connectTimeout = 30000; // 30 saniye
  static const int receiveTimeout = 30000; // 30 saniye

  // HTTP Headers
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };

  // Geliştirme ortamında mı kontrol et
  static bool get isDevelopment => const bool.fromEnvironment(
        'FLUTTER_DEV',
        defaultValue: true,
      );
}
