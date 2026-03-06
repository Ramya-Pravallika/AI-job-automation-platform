import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }
}
