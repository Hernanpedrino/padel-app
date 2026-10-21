import 'perfil.dart';
import 'turno.dart';

class SolicitudPartido {
  final String id;
  final String usuarioId;
  final String estado;
  final Jugador usuario;

  SolicitudPartido({required this.id, required this.usuarioId, required this.estado, required this.usuario});

  factory SolicitudPartido.fromJson(Map<String, dynamic> json) {
    return SolicitudPartido(
      id: json['id'],
      usuarioId: json['usuarioId'],
      estado: json['estado'],
      usuario: Jugador.fromJson(json['usuario']),
    );
  }
}

class Partido {
  final String id;
  final String categoria;
  final String rama;
  final int jugadoresBuscados;
  final String? descripcion;
  final String estado;
  final Turno turno;
  final String complejoNombre;
  final String complejoDireccion;
  final Jugador creador;
  // El backend solo manda las solicitudes pendientes y aceptadas
  final List<SolicitudPartido> jugadores;

  Partido({
    required this.id,
    required this.categoria,
    required this.rama,
    required this.jugadoresBuscados,
    this.descripcion,
    required this.estado,
    required this.turno,
    required this.complejoNombre,
    required this.complejoDireccion,
    required this.creador,
    required this.jugadores,
  });

  List<SolicitudPartido> get aceptados => jugadores.where((j) => j.estado == 'ACEPTADA').toList();
  List<SolicitudPartido> get pendientes => jugadores.where((j) => j.estado == 'PENDIENTE').toList();
  int get cuposLibres => jugadoresBuscados - aceptados.length;

  SolicitudPartido? solicitudDe(String usuarioId) {
    for (final j in jugadores) {
      if (j.usuarioId == usuarioId) return j;
    }
    return null;
  }

  factory Partido.fromJson(Map<String, dynamic> json) {
    final complejo = json['turno']['cancha']['complejo'];
    return Partido(
      id: json['id'],
      categoria: json['categoria'],
      rama: json['rama'],
      jugadoresBuscados: json['jugadoresBuscados'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      turno: Turno.fromJson(json['turno']),
      complejoNombre: complejo['nombre'],
      complejoDireccion: complejo['direccion'],
      creador: Jugador.fromJson(json['creador']),
      jugadores: (json['jugadores'] as List).map((j) => SolicitudPartido.fromJson(j)).toList(),
    );
  }
}
