import 'package:flutter/material.dart';
import '../screens/clases_screen.dart';
import '../screens/mis_reservas_screen.dart';
import '../screens/partido_detalle_screen.dart';
import '../screens/torneos_screen.dart';

// Pantalla a la que lleva una novedad o notificación según su tipo; null si no lleva a ninguna
Widget? pantallaDeAviso(String tipo, String? refId) {
  if (tipo.contains('PARTIDO') || tipo.startsWith('SOLICITUD') || tipo == 'JUGADOR_SE_BAJO') {
    return refId != null && refId.isNotEmpty ? PartidoDetalleScreen(partidoId: refId) : null;
  }
  if (tipo == 'TORNEO_ABIERTO') return const TorneosScreen();
  if (tipo.contains('TORNEO') || tipo == 'INSCRIPTO_POR_COMPANERO') return const TorneosScreen(pestanaInicial: 1);
  if (tipo.contains('CLASE')) return const ClasesScreen(pestanaInicial: 1);
  if (tipo.contains('RESERVA') || tipo == 'TURNO_CANCELADO') return const MisReservasScreen();
  return null;
}
