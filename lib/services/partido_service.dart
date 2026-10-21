import '../models/partido.dart';
import 'api_client.dart';

class PartidoService {
  final ApiClient _api = ApiClient();

  Future<List<Partido>> buscar({String? categoria, String? rama}) async {
    final List<dynamic> data = await _api.get('/partidos', query: {'categoria': categoria, 'rama': rama});
    return data.map((json) => Partido.fromJson(json)).toList();
  }

  Future<List<Partido>> misPartidos() async {
    final List<dynamic> data = await _api.get('/partidos/mis-partidos');
    return data.map((json) => Partido.fromJson(json)).toList();
  }

  Future<Partido> detalle(String id) async => Partido.fromJson(await _api.get('/partidos/$id'));

  Future<void> crear({
    required String turnoId,
    required String categoria,
    required String rama,
    required int jugadoresBuscados,
    String? descripcion,
  }) =>
      _api.post('/partidos', {
        'turnoId': turnoId,
        'categoria': categoria,
        'rama': rama,
        'jugadoresBuscados': jugadoresBuscados,
        if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
      });

  Future<void> pedirSumarse(String partidoId) => _api.post('/partidos/$partidoId/solicitudes');

  Future<void> salir(String partidoId) => _api.patch('/partidos/$partidoId/solicitudes/salir');

  Future<void> responder(String partidoId, String solicitudId, {required bool aceptar}) =>
      _api.patch('/partidos/$partidoId/solicitudes/$solicitudId', {'estado': aceptar ? 'ACEPTADA' : 'RECHAZADA'});

  Future<void> cancelar(String partidoId) => _api.patch('/partidos/$partidoId/cancelar');
}
