class Cancha {
  final String id;
  final String nombre;
  final String tipo;

  Cancha({required this.id, required this.nombre, required this.tipo});

  factory Cancha.fromJson(Map<String, dynamic> json) {
    return Cancha(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
    );
  }
}

class Turno {
  final String id;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final double precio;
  final String estado;
  final Cancha cancha;

  Turno({
    required this.id,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.precio,
    required this.estado,
    required this.cancha,
  });

  factory Turno.fromJson(Map<String, dynamic> json) {
    return Turno(
      id: json['id'],
      fechaHoraInicio: DateTime.parse(json['fechaHoraInicio']),
      fechaHoraFin: DateTime.parse(json['fechaHoraFin']),
      precio: double.parse(json['precio'].toString()),
      estado: json['estado'],
      cancha: Cancha.fromJson(json['cancha']),
    );
  }
}