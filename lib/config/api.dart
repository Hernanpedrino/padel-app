class ApiConfig {
  // Se puede cambiar sin tocar código: flutter run --dart-define=API_URL=http://<ip-de-la-pc>:3002
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.191:3002',
  );

  // Si el backend no responde en este tiempo la llamada falla en vez de quedar esperando
  static const Duration timeout = Duration(seconds: 10);
}

// Error de red (backend caído, otra red, timeout) para mostrar un mensaje claro
class SinConexionException implements Exception {
  @override
  String toString() =>
      'No se pudo conectar con el servidor. Revisá que estés en la misma red WiFi y que el backend esté levantado.';
}
