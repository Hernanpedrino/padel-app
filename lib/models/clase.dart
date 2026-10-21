import '../utils/formato.dart';

class Clase {
  final String id;
  final String profesor;
  final String? nivel;
  final String? descripcion;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final int cupo;
  final double precio;
  final String estado;
  final String canchaNombre;
  final String complejoNombre;
  // Inscripciones confirmadas; solo viene en el listado de clases disponibles
  final int confirmadas;

  Clase({
    required this.id,
    required this.profesor,
    this.nivel,
    this.descripcion,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.cupo,
    required this.precio,
    required this.estado,
    required this.canchaNombre,
    required this.complejoNombre,
    required this.confirmadas,
  });

  factory Clase.fromJson(Map<String, dynamic> json) {
    return Clase(
      id: json['id'],
      profesor: json['profesor'],
      nivel: json['nivel'],
      descripcion: json['descripcion'],
      fechaHoraInicio: fechaLocal(json['fechaHoraInicio']),
      fechaHoraFin: fechaLocal(json['fechaHoraFin']),
      cupo: json['cupo'],
      precio: precioDe(json['precio']),
      estado: json['estado'],
      canchaNombre: json['cancha']?['nombre'] ?? '',
      complejoNombre: json['complejo']?['nombre'] ?? '',
      confirmadas: json['_count']?['inscripciones'] ?? 0,
    );
  }
}

class InscripcionClase {
  final String id;
  final String estado;
  final Clase clase;

  InscripcionClase({required this.id, required this.estado, required this.clase});

  bool get activa => estado == 'PENDIENTE' || estado == 'CONFIRMADA';

  factory InscripcionClase.fromJson(Map<String, dynamic> json) {
    return InscripcionClase(
      id: json['id'],
      estado: json['estado'],
      clase: Clase.fromJson(json['clase']),
    );
  }
}
