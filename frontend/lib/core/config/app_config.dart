import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080',
      );

  static String get apiUrl => const String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost:8080',
      );

  static const int connectTimeout = 30000; // 30 saniye
  static const int receiveTimeout = 30000; // 30 saniye

  // Geliştirme ortamında mı kontrol et
  static bool get isDevelopment => const bool.fromEnvironment(
        'FLUTTER_DEV',
        defaultValue: true,
      );
}
