import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/complejo.dart';
import '../models/turno.dart';
import 'auth_service.dart';

class TurnoService {
  final AuthService _authService = AuthService();

  Future<List<Complejo>> getComplejos() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/complejos'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Complejo.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<Turno>> getTurnosDisponibles(String complejoId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/turnos/disponibles/$complejoId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Turno.fromJson(json)).toList();
    }
    return [];
  }
}