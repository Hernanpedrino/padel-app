import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/clase.dart';
import 'package:padel_app/models/complejo.dart';
import 'package:padel_app/models/novedad.dart';
import 'package:padel_app/models/partido.dart';
import 'package:padel_app/models/perfil.dart';
import 'package:padel_app/models/reserva.dart';
import 'package:padel_app/models/torneo.dart';

// Los fixtures son respuestas reales del backend: si cambia la forma de un JSON, estos tests lo detectan
dynamic fixture(String nombre) => jsonDecode(File('test/fixtures/$nombre.json').readAsStringSync());

List<T> lista<T>(String nombre, T Function(Map<String, dynamic>) fromJson) =>
    (fixture(nombre) as List).map((j) => fromJson(j as Map<String, dynamic>)).toList();

void main() {
  test('perfil', () {
    final p = Perfil.fromJson(fixture('perfil'));
    expect(p.email, 'juan@gmail.com');
    expect(p.categoria, 'SEXTA');
    expect(p.completo, isTrue);
  });

  test('complejos y favoritos', () {
    expect(lista('complejos', Complejo.fromJson), isNotEmpty);
    expect(lista('favoritos', Complejo.fromJson), hasLength(1));
  });

  test('novedades', () {
    final novedades = lista('novedades', Novedad.fromJson);
    expect(novedades.map((n) => n.tipo), containsAll(['SOLICITUDES_PARTIDO', 'RESERVA_PROXIMA', 'INSCRIPCION_TORNEO']));
    // Las fechas llegan en UTC y se convierten a la hora local
    expect(novedades.first.fecha.isUtc, isFalse);
  });

  test('mis reservas', () {
    final reservas = lista('mis_reservas', Reserva.fromJson);
    expect(reservas.first.complejoNombre, isNotNull);
    expect(reservas.first.turno.precio, 1500);
  });

  test('partidos', () {
    final abiertos = lista('partidos', Partido.fromJson);
    expect(abiertos, isNotEmpty);
    final detalle = Partido.fromJson(fixture('partido_detalle'));
    expect(detalle.jugadoresBuscados, 2);
    expect(detalle.pendientes, hasLength(1));
    expect(detalle.cuposLibres, 2);
    expect(detalle.solicitudDe(detalle.pendientes.first.usuarioId), isNotNull);
    expect(lista('mis_partidos', Partido.fromJson).first.creador.nombre, 'Juan');
  });

  test('torneos', () {
    final torneos = lista('torneos', Torneo.fromJson);
    expect(torneos.first.precioInscripcion, 10000);
    expect(torneos.first.complejoNombre, isNotEmpty);
    final inscripciones = lista('torneos_mis_inscripciones', InscripcionTorneo.fromJson);
    final i = inscripciones.first;
    expect(i.estado, 'PENDIENTE');
    expect(i.companeroDe(i.jugador1.id).nombre, 'PRUEBA');
  });

  test('clases', () {
    final clases = lista('clases', Clase.fromJson);
    expect(clases.first.canchaNombre, isNotEmpty);
    expect(clases.first.cupo, 4);
    final inscripciones = lista('clases_mis_inscripciones', InscripcionClase.fromJson);
    expect(inscripciones.first.activa, isTrue);
    expect(inscripciones.first.clase.complejoNombre, isNotEmpty);
  });
}
