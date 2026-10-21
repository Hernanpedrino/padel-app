import '../models/complejo.dart';
import '../models/notificacion.dart';
import '../models/novedad.dart';
import '../models/perfil.dart';
import 'api_client.dart';

class UsuarioService {
  final ApiClient _api = ApiClient();

  Future<Perfil> getPerfil() async => Perfil.fromJson(await _api.get('/usuarios/me'));

  Future<Perfil> actualizarPerfil(Map<String, dynamic> datos) async =>
      Perfil.fromJson(await _api.patch('/usuarios/me', datos));

  Future<List<Novedad>> novedades() async {
    final List<dynamic> data = await _api.get('/usuarios/me/novedades');
    return data.map((json) => Novedad.fromJson(json)).toList();
  }

  Future<List<Complejo>> favoritos() async {
    final List<dynamic> data = await _api.get('/usuarios/me/favoritos');
    return data.map((json) => Complejo.fromJson(json)).toList();
  }

  Future<void> agregarFavorito(String complejoId) => _api.post('/usuarios/me/favoritos/$complejoId');

  Future<void> quitarFavorito(String complejoId) => _api.delete('/usuarios/me/favoritos/$complejoId');

  Future<BandejaNotificaciones> notificaciones() async =>
      BandejaNotificaciones.fromJson(await _api.get('/usuarios/me/notificaciones'));

  Future<void> marcarNotificacionesLeidas() => _api.patch('/usuarios/me/notificaciones/leidas');
}
