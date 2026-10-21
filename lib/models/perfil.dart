// Datos públicos de otro jugador (creador de un partido, compañero, etc.)
class Jugador {
  final String id;
  final String nombre;
  final String apellido;
  final String? categoria;
  final String? genero;

  Jugador({required this.id, required this.nombre, required this.apellido, this.categoria, this.genero});

  String get nombreCompleto => '$nombre $apellido';

  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      categoria: json['categoria'],
      genero: json['genero'],
    );
  }
}

// Perfil del usuario logueado
class Perfil {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final String? categoria;
  final String? genero;

  Perfil({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.categoria,
    this.genero,
  });

  // Sin categoría y género no puede sumarse a partidos ni torneos
  bool get completo => categoria != null && genero != null;

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      telefono: json['telefono'],
      categoria: json['categoria'],
      genero: json['genero'],
    );
  }
}
