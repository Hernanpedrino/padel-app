class ApiConfig {
  // En desarrollo con el celular por USB: `adb reverse tcp:3002 tcp:3002` y localhost
  // llega al backend de la PC sin depender del WiFi.
  // Para otra dirección: flutter run --dart-define=API_URL=http://<ip-de-la-pc>:3002
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3002',
  );

  // Si el servidor no responde en este tiempo la llamada falla en vez de quedar esperando
  static const Duration timeout = Duration(seconds: 10);
}

// Error de red (sin conexión, servidor caído, timeout); el mensaje lo ve el usuario final
class SinConexionException implements Exception {
  @override
  String toString() => 'No se pudo conectar. Revisá tu conexión a internet e intentá de nuevo.';
}
