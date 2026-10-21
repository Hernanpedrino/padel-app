import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AuthService {
  static const String _tokenKey = 'token';

  Future<http.Response> _post(String ruta, Map<String, dynamic> body) async {
    try {
      return await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$ruta'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw SinConexionException();
    } on SocketException {
      throw SinConexionException();
    } on http.ClientException {
      throw SinConexionException();
    }
  }

  Future<bool> login(String email, String password) async {
    final response = await _post('/auth/usuario/login', {'email': email, 'password': password});

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, data['token']);
      return true;
    }
    return false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<String?> registrar({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String password,
  }) async {
    final response = await _post('/auth/usuario/registro', {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'password': password,
    });

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, data['token']);
      return data['token'];
    }
    return null;
  }
}
