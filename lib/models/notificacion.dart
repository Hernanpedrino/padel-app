import '../utils/formato.dart';

// Aviso de un evento (te confirmaron en un partido, inscripción confirmada, etc.)
class Notificacion {
  final String id;
  final String tipo;
  final String titulo;
  final String cuerpo;
  final String? refId;
  final bool leida;
  final DateTime creadoEn;

  Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    this.refId,
    required this.leida,
    required this.creadoEn,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      tipo: json['tipo'],
      titulo: json['titulo'],
      cuerpo: json['cuerpo'],
      refId: json['refId'],
      leida: json['leida'],
      creadoEn: fechaLocal(json['creadoEn']),
    );
  }
}

class BandejaNotificaciones {
  final int noLeidas;
  final List<Notificacion> items;

  BandejaNotificaciones({required this.noLeidas, required this.items});

  factory BandejaNotificaciones.fromJson(Map<String, dynamic> json) {
    return BandejaNotificaciones(
      noLeidas: json['noLeidas'],
      items: (json['items'] as List).map((j) => Notificacion.fromJson(j)).toList(),
    );
  }
}
