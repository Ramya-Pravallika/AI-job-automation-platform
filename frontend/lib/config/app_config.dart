import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _envBaseUrl = String.fromEnvironment('BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static List<String> get candidateBaseUrls {
    if (_envBaseUrl.isNotEmpty) {
      return [_envBaseUrl];
    }

    if (kIsWeb) {
      return const [
        'http://127.0.0.1:8000',
        'http://127.0.0.1:8010',
        'http://localhost:8000',
        'http://localhost:8010',
      ];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return const [
        'http://10.0.2.2:8000',
        'http://10.0.2.2:8010',
        'http://127.0.0.1:8000',
        'http://127.0.0.1:8010',
      ];
    }

    return const [
      'http://127.0.0.1:8000',
      'http://127.0.0.1:8010',
      'http://localhost:8000',
      'http://localhost:8010',
    ];
  }
}
