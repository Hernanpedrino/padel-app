import '../utils/formato.dart';

// Ítem del feed de inicio; refId apunta al partido, reserva, torneo o clase
class Novedad {
  final String tipo;
  final String titulo;
  final String detalle;
  final DateTime fecha;
  final String refId;

  Novedad({required this.tipo, required this.titulo, required this.detalle, required this.fecha, required this.refId});

  factory Novedad.fromJson(Map<String, dynamic> json) {
    return Novedad(
      tipo: json['tipo'],
      titulo: json['titulo'],
      detalle: json['detalle'],
      fecha: fechaLocal(json['fecha']),
      refId: json['refId'],
    );
  }
}
