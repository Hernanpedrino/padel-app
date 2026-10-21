import '../models/clase.dart';
import 'api_client.dart';

class ClaseService {
  final ApiClient _api = ApiClient();

  Future<List<Clase>> disponibles() async {
    final List<dynamic> data = await _api.get('/clases');
    return data.map((json) => Clase.fromJson(json)).toList();
  }

  Future<List<InscripcionClase>> misInscripciones() async {
    final List<dynamic> data = await _api.get('/clases/mis-inscripciones');
    return data.map((json) => InscripcionClase.fromJson(json)).toList();
  }

  Future<void> inscribirse(String claseId) => _api.post('/clases/$claseId/inscripciones');

  Future<void> cancelarInscripcion(String inscripcionId) => _api.patch('/clases/inscripciones/$inscripcionId/cancelar');
}
