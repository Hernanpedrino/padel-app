import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notificacion.dart';
import '../providers/notificaciones_provider.dart';
import '../utils/formato.dart';
import '../utils/navegacion.dart';
import '../widgets/comunes.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  // Las que estaban sin leer al entrar se siguen resaltando aunque ya se marcaron como leídas
  Set<String> _resaltadas = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final provider = context.read<NotificacionesProvider>();
    await provider.refrescar();
    if (!mounted) return;
    setState(() {
      _resaltadas = {..._resaltadas, ...provider.items.where((n) => !n.leida).map((n) => n.id)};
      _loading = false;
    });
    provider.marcarLeidas();
  }

  static const _iconos = {
    'SOLICITUD_PARTIDO': (Icons.person_add, Colors.orange),
    'SOLICITUD_ACEPTADA': (Icons.check_circle, Colors.green),
    'SOLICITUD_RECHAZADA': (Icons.cancel, Colors.red),
    'PARTIDO_COMPLETO': (Icons.groups, Colors.green),
    'JUGADOR_SE_BAJO': (Icons.person_remove, Colors.orange),
    'PARTIDO_CANCELADO': (Icons.event_busy, Colors.red),
    'TURNO_CANCELADO': (Icons.event_busy, Colors.red),
    'INSCRIPTO_POR_COMPANERO': (Icons.emoji_events, Colors.purple),
    'INSCRIPCION_TORNEO_CONFIRMADA': (Icons.emoji_events, Colors.green),
    'INSCRIPCION_TORNEO_RECHAZADA': (Icons.emoji_events, Colors.red),
    'INSCRIPCION_CLASE_CONFIRMADA': (Icons.school, Colors.green),
    'INSCRIPCION_CLASE_RECHAZADA': (Icons.school, Colors.red),
    'CLASE_CANCELADA': (Icons.school, Colors.red),
  };

  @override
  Widget build(BuildContext context) {
    final items = context.watch<NotificacionesProvider>().items;

    return Scaffold(
      appBar: barraApp('Notificaciones'),
      body: ListaRefrescable(
        cargando: _loading,
        cantidad: items.length,
        onRefresh: _cargar,
        vacio: const Vacio(icono: Icons.notifications_none, texto: 'No tenés notificaciones.'),
        itemBuilder: (_, i) => _tarjeta(items[i]),
      ),
    );
  }

  Widget _tarjeta(Notificacion n) {
    final (icono, color) = _iconos[n.tipo] ?? (Icons.notifications, colorPrimario);
    final nueva = _resaltadas.contains(n.id);
    final destino = pantallaDeAviso(n.tipo, n.refId);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: nueva ? colorPrimario.withValues(alpha: 0.06) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: IconoCaja(icono, color: color),
        title: Text(n.titulo, style: TextStyle(fontWeight: nueva ? FontWeight.bold : FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(n.cuerpo),
            const SizedBox(height: 4),
            Text(hace(n.creadoEn), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        trailing: nueva ? const Icon(Icons.circle, size: 10, color: colorPrimario) : null,
        onTap: destino == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => destino)),
      ),
    );
  }
}
