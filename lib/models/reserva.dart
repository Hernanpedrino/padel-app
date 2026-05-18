import 'turno.dart';

class Reserva {
  final String id;
  final String estado;
  final DateTime creadoEn;
  final Turno turno;

  Reserva({
    required this.id,
    required this.estado,
    required this.creadoEn,
    required this.turno,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      estado: json['estado'],
      creadoEn: DateTime.parse(json['creadoEn']),
      turno: Turno.fromJson(json['turno']),
    );
  }
}