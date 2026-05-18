import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/reserva.dart';
import 'auth_service.dart';

class ReservaService {
  final AuthService _authService = AuthService();

  Future<List<Reserva>> getMisReservas() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/reservas/mis-reservas'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reserva.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> crearReserva(String turnoId) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/reservas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'turnoId': turnoId}),
    );

    return response.statusCode == 201;
  }

  Future<bool> cancelarReserva(String reservaId) async {
    final token = await _authService.getToken();
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/reservas/$reservaId/cancelar'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }
}