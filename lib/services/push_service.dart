import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_client.dart';

// Datos que manda el backend en cada push (tipo de aviso y a qué partido, torneo, etc. lleva)
typedef AvisoPush = ({String tipo, String? refId});

// Notificaciones push con Firebase Cloud Messaging.
// Con la app cerrada o en segundo plano Android muestra el aviso solo; con la app abierta
// lo maneja NotificacionesProvider (aviso dentro de la app y contador de la campana).
class PushService {
  // Mismo canal que usa el backend al enviar (android.notification.channelId)
  static const String canal = 'padel_avisos';
  static bool _disponible = false;
  // Firebase Installation ID de este celular: es el destino de los push en el backend
  static String? _fid;
  static StreamSubscription<String>? _registro;

  final ApiClient _api = ApiClient();

  // Se llama una vez en main(); si Firebase no está configurado la app sigue sin push
  static Future<void> inicializar() async {
    try {
      await Firebase.initializeApp();
      await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            canal,
            'Avisos de partidos y torneos',
            description: 'Confirmaciones, solicitudes y cancelaciones',
            importance: Importance.high,
          ));
      _disponible = true;
    } catch (e) {
      debugPrint('Push no disponible: $e');
    }
  }

  // Pide permiso (Android 13+) y registra el celular en el backend para recibir avisos.
  // FCM informa el FID por onRegistered, también cuando cambia.
  Future<void> registrar() async {
    if (!_disponible) return;
    try {
      final permiso = await FirebaseMessaging.instance.requestPermission();
      if (permiso.authorizationStatus == AuthorizationStatus.denied) return;
      await _registro?.cancel();
      _registro = FirebaseMessaging.instance.onRegistered.listen((fid) {
        _fid = fid;
        _api.post('/usuarios/me/dispositivos', {'token': fid, 'plataforma': defaultTargetPlatform.name}).catchError((_) {});
      });
      await FirebaseMessaging.instance.register();
    } catch (e) {
      debugPrint('No se pudo registrar el celular para push: $e');
    }
  }

  // Al cerrar sesión el celular deja de recibir los avisos de ese usuario
  Future<void> darDeBaja() async {
    await _registro?.cancel();
    _registro = null;
    final fid = _fid;
    if (fid == null) return;
    try {
      await _api.post('/usuarios/me/dispositivos/baja', {'token': fid});
    } catch (_) {
      // Si falla, el backend reasigna el celular al próximo usuario que inicie sesión
    }
  }

  // onRecibido: push con la app abierta. onAbierto: el usuario tocó una notificación del sistema.
  List<StreamSubscription> escuchar({
    required void Function() onRecibido,
    required void Function(AvisoPush aviso) onAbierto,
  }) {
    if (!_disponible) return [];
    AvisoPush aviso(RemoteMessage m) => (tipo: m.data['tipo'] as String? ?? '', refId: m.data['refId'] as String?);

    // Si la app se abrió desde una notificación estando cerrada
    FirebaseMessaging.instance.getInitialMessage().then((m) {
      if (m != null) onAbierto(aviso(m));
    });
    return [
      FirebaseMessaging.onMessage.listen((_) => onRecibido()),
      FirebaseMessaging.onMessageOpenedApp.listen((m) => onAbierto(aviso(m))),
    ];
  }
}
