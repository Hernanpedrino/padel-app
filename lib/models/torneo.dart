import '../utils/formato.dart';
import 'perfil.dart';

class Torneo {
  final String id;
  final String nombre;
  final String? descripcion;
  final String categoria;
  final String rama;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final DateTime cierreInscripcion;
  final int cupoParejas;
  final double precioInscripcion;
  final String estado;
  final String complejoNombre;
  // Parejas confirmadas; solo viene en el listado de torneos disponibles
  final int confirmadas;

  Torneo({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.categoria,
    required this.rama,
    required this.fechaInicio,
    required this.fechaFin,
    required this.cierreInscripcion,
    required this.cupoParejas,
    required this.precioInscripcion,
    required this.estado,
    required this.complejoNombre,
    required this.confirmadas,
  });

  factory Torneo.fromJson(Map<String, dynamic> json) {
    return Torneo(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      rama: json['rama'],
      fechaInicio: fechaLocal(json['fechaInicio']),
      fechaFin: fechaLocal(json['fechaFin']),
      cierreInscripcion: fechaLocal(json['cierreInscripcion']),
      cupoParejas: json['cupoParejas'],
      precioInscripcion: precioDe(json['precioInscripcion']),
      estado: json['estado'],
      complejoNombre: json['complejo']?['nombre'] ?? '',
      confirmadas: json['_count']?['inscripciones'] ?? 0,
    );
  }
}

class InscripcionTorneo {
  final String id;
  final String estado;
  final Torneo torneo;
  final Jugador jugador1;
  final Jugador jugador2;

  InscripcionTorneo({
    required this.id,
    required this.estado,
    required this.torneo,
    required this.jugador1,
    required this.jugador2,
  });

  bool get activa => estado == 'PENDIENTE' || estado == 'CONFIRMADA';

  Jugador companeroDe(String usuarioId) => jugador1.id == usuarioId ? jugador2 : jugador1;

  factory InscripcionTorneo.fromJson(Map<String, dynamic> json) {
    return InscripcionTorneo(
      id: json['id'],
      estado: json['estado'],
      torneo: Torneo.fromJson(json['torneo']),
      jugador1: Jugador.fromJson(json['jugador1']),
      jugador2: Jugador.fromJson(json['jugador2']),
    );
  }
}
