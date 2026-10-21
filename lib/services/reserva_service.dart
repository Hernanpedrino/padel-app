import '../models/reserva.dart';
import 'api_client.dart';

// Los errores (turno ya tomado, etc.) llegan como ApiException con el mensaje del backend
class ReservaService {
  final ApiClient _api = ApiClient();

  Future<List<Reserva>> getMisReservas() async {
    final List<dynamic> data = await _api.get('/reservas/mis-reservas');
    return data.map((json) => Reserva.fromJson(json)).toList();
  }

  Future<void> crearReserva(String turnoId) => _api.post('/reservas', {'turnoId': turnoId});

  Future<void> cancelarReserva(String reservaId) => _api.patch('/reservas/$reservaId/cancelar');
}
