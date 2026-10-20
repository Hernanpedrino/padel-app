class ApiConfig {
  // Se puede cambiar sin tocar código: flutter run --dart-define=API_URL=http://<ip-de-la-pc>:3002
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.191:3002',
  );
}
