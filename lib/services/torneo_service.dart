import '../models/torneo.dart';
import 'api_client.dart';

class TorneoService {
  final ApiClient _api = ApiClient();

  Future<List<Torneo>> disponibles() async {
    final List<dynamic> data = await _api.get('/torneos');
    return data.map((json) => Torneo.fromJson(json)).toList();
  }

  Future<List<InscripcionTorneo>> misInscripciones() async {
    final List<dynamic> data = await _api.get('/torneos/mis-inscripciones');
    return data.map((json) => InscripcionTorneo.fromJson(json)).toList();
  }

  Future<void> inscribirse(String torneoId, String companeroEmail) =>
      _api.post('/torneos/$torneoId/inscripciones', {'companeroEmail': companeroEmail});

  Future<void> cancelarInscripcion(String inscripcionId) => _api.patch('/torneos/inscripciones/$inscripcionId/cancelar');
}
