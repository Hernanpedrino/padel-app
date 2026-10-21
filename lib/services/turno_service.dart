import '../models/complejo.dart';
import '../models/turno.dart';
import 'api_client.dart';

class TurnoService {
  final ApiClient _api = ApiClient();

  Future<List<Complejo>> getComplejos() async {
    final List<dynamic> data = await _api.get('/complejos');
    return data.map((json) => Complejo.fromJson(json)).toList();
  }

  Future<List<Turno>> getTurnosDisponibles(String complejoId) async {
    final List<dynamic> data = await _api.get('/turnos/disponibles/$complejoId');
    return data.map((json) => Turno.fromJson(json)).toList();
  }
}
