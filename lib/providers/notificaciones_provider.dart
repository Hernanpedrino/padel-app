import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notificacion.dart';
import '../services/usuario_service.dart';

// Contador de la campana y aviso de notificaciones nuevas mientras la app está abierta.
// Con la app cerrada los avisos llegan por push (Firebase).
class NotificacionesProvider extends ChangeNotifier {
  static const Duration intervalo = Duration(seconds: 45);

  final UsuarioService _service = UsuarioService();
  Timer? _timer;
  bool _inicializado = false;
  String? _masRecienteId;

  int noLeidas = 0;
  List<Notificacion> items = [];
  // Lo asigna la pantalla principal para mostrar un aviso cuando llega una nueva
  void Function(Notificacion nueva)? onNueva;

  void iniciar() {
    refrescar();
    _timer?.cancel();
    _timer = Timer.periodic(intervalo, (_) => refrescar());
  }

  void detener() {
    _timer?.cancel();
    _timer = null;
    _inicializado = false;
    _masRecienteId = null;
    noLeidas = 0;
    items = [];
  }

  Future<void> refrescar() async {
    try {
      final bandeja = await _service.notificaciones();
      // En la primera carga no se avisa: son las que ya estaban
      final nuevas = !_inicializado
          ? <Notificacion>[]
          : bandeja.items.takeWhile((n) => n.id != _masRecienteId).where((n) => !n.leida).toList();
      _inicializado = true;
      if (bandeja.items.isNotEmpty) _masRecienteId = bandeja.items.first.id;
      noLeidas = bandeja.noLeidas;
      items = bandeja.items;
      notifyListeners();
      if (nuevas.isNotEmpty) onNueva?.call(nuevas.first);
    } catch (_) {
      // Sin conexión: se reintenta en el próximo ciclo
    }
  }

  Future<void> marcarLeidas() async {
    if (noLeidas == 0) return;
    try {
      await _service.marcarNotificacionesLeidas();
      noLeidas = 0;
      notifyListeners();
    } catch (_) {
      // Quedan como no leídas y se marcan la próxima vez que se abra la bandeja
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
