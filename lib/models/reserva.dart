import '../utils/formato.dart';
import 'turno.dart';

class Reserva {
  final String id;
  final String estado;
  final DateTime creadoEn;
  final Turno turno;
  // mis-reservas incluye el complejo de la cancha
  final String? complejoNombre;

  Reserva({
    required this.id,
    required this.estado,
    required this.creadoEn,
    required this.turno,
    this.complejoNombre,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      estado: json['estado'],
      creadoEn: fechaLocal(json['creadoEn']),
      turno: Turno.fromJson(json['turno']),
      complejoNombre: json['turno']?['cancha']?['complejo']?['nombre'],
    );
  }
}
