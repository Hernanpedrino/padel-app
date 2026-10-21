import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';

// Error que devuelve el backend, con su mensaje listo para mostrar
class ApiException implements Exception {
  final String mensaje;
  final int status;
  ApiException(this.mensaje, this.status);

  @override
  String toString() => mensaje;
}

// Cliente HTTP compartido: agrega el token, corta por timeout y traduce los errores
class ApiClient {
  // AuthProvider lo usa para cerrar la sesión cuando el token venció
  static void Function()? onNoAutorizado;

  static final http.Client _http = http.Client();
  final AuthService _authService = AuthService();

  Future<dynamic> get(String ruta, {Map<String, String?>? query}) => _enviar('GET', ruta, query: query);
  Future<dynamic> post(String ruta, [Object? body]) => _enviar('POST', ruta, body: body);
  Future<dynamic> patch(String ruta, [Object? body]) => _enviar('PATCH', ruta, body: body);
  Future<dynamic> delete(String ruta) => _enviar('DELETE', ruta);

  Future<dynamic> _enviar(String metodo, String ruta, {Object? body, Map<String, String?>? query}) async {
    final token = await _authService.getToken();
    final parametros = {
      for (final e in (query ?? {}).entries)
        if (e.value != null && e.value!.isNotEmpty) e.key: e.value!,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}$ruta').replace(queryParameters: parametros.isEmpty ? null : parametros);

    final request = http.Request(metodo, uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _http.send(request).timeout(ApiConfig.timeout));
    } on TimeoutException {
      throw SinConexionException();
    } on SocketException {
      throw SinConexionException();
    } on http.ClientException {
      throw SinConexionException();
    }

    final texto = utf8.decode(response.bodyBytes);
    final data = texto.isEmpty ? null : jsonDecode(texto);

    if (response.statusCode == 401) {
      onNoAutorizado?.call();
      throw ApiException('Tu sesión venció. Volvé a ingresar.', 401);
    }
    if (response.statusCode >= 400) {
      final mensaje = data is Map ? data['message'] : null;
      throw ApiException(
        mensaje is List ? mensaje.join('. ') : (mensaje?.toString() ?? 'Ocurrió un error. Intentá de nuevo.'),
        response.statusCode,
      );
    }
    return data;
  }
}
