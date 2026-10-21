import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/complejo.dart';
import '../models/novedad.dart';
import '../providers/auth_provider.dart';
import '../providers/notificaciones_provider.dart';
import '../services/usuario_service.dart';
import '../utils/errores.dart';
import '../utils/formato.dart';
import '../utils/navegacion.dart';
import '../widgets/comunes.dart';
import 'clases_screen.dart';
import 'mis_reservas_screen.dart';
import 'notificaciones_screen.dart';
import 'torneos_screen.dart';
import 'turnos_screen.dart';

class InicioScreen extends StatefulWidget {
  // Cambia de pestaña en la barra inferior (ej. ir a Partidos o a Perfil)
  final void Function(int indice) onIrA;
  final int indicePerfil;
  const InicioScreen({super.key, required this.onIrA, required this.indicePerfil});

  @override
  State<InicioScreen> createState() => InicioScreenState();
}

class InicioScreenState extends State<InicioScreen> {
  final UsuarioService _usuarioService = UsuarioService();
  List<Novedad> _novedades = [];
  List<Complejo> _favoritos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    final auth = context.read<AuthProvider>();
    context.read<NotificacionesProvider>().refrescar();
    try {
      final resultados = await Future.wait([_usuarioService.novedades(), _usuarioService.favoritos()]);
      if (auth.perfil == null) await auth.recargarPerfil();
      if (!mounted) return;
      setState(() {
        _novedades = resultados[0] as List<Novedad>;
        _favoritos = resultados[1] as List<Complejo>;
      });
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
    cargar();
  }

  void _abrirNovedad(Novedad n) {
    final destino = pantallaDeAviso(n.tipo, n.refId);
    if (destino != null) _abrir(destino);
  }

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<AuthProvider>().perfil;
    final noLeidas = context.watch<NotificacionesProvider>().noLeidas;

    return Scaffold(
      appBar: barraApp('Padel App', acciones: [
        IconButton(
          tooltip: 'Notificaciones',
          icon: Badge(
            isLabelVisible: noLeidas > 0,
            label: Text(noLeidas > 99 ? '99+' : '$noLeidas'),
            child: Icon(noLeidas > 0 ? Icons.notifications_active : Icons.notifications_none),
          ),
          onPressed: () => _abrir(const NotificacionesScreen()),
        ),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: cargar,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Text(
                      perfil != null ? '¡Hola, ${perfil.nombre}!' : '¡Hola!',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (perfil != null && !perfil.completo) _avisoPerfil(),
                  _accesos(),
                  TituloSeccion('Complejos favoritos'),
                  _seccionFavoritos(),
                  TituloSeccion('Novedades'),
                  if (_novedades.isEmpty)
                    const Vacio(icono: Icons.notifications_none, texto: 'No tenés novedades por ahora.')
                  else
                    ..._novedades.map(_tarjetaNovedad),
                ],
              ),
            ),
    );
  }

  Widget _avisoPerfil() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.info_outline, color: Colors.orange),
        title: const Text('Completá tu perfil'),
        subtitle: const Text('Cargá tu categoría y género para sumarte a partidos y torneos.'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => widget.onIrA(widget.indicePerfil),
      ),
    );
  }

  Widget _accesos() {
    final accesos = [
      (Icons.groups, 'Partidos', () => widget.onIrA(1)),
      (Icons.emoji_events, 'Torneos', () => _abrir(const TorneosScreen())),
      (Icons.school, 'Clases', () => _abrir(const ClasesScreen())),
      (Icons.calendar_today, 'Mis reservas', () => _abrir(const MisReservasScreen())),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Row(
        children: accesos
            .map((a) => Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: a.$3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          IconoCaja(a.$1),
                          const SizedBox(height: 6),
                          Text(a.$2, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _seccionFavoritos() {
    if (_favoritos.isEmpty) {
      return Vacio(
        icono: Icons.star_border,
        texto: 'Marcá con ⭐ tus complejos en "Reservar" para tenerlos a mano.',
        accion: 'Ver complejos',
        onAccion: () => widget.onIrA(2),
      );
    }
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _favoritos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = _favoritos[i];
          return SizedBox(
            width: 200,
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _abrir(TurnosScreen(complejo: c)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(c.nombre,
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Text(c.direccion, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      const Text('Ver turnos →', style: TextStyle(color: colorPrimario, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static const _iconos = {
    'SOLICITUDES_PARTIDO': (Icons.person_add, Colors.orange),
    'PARTIDO_CONFIRMADO': (Icons.check_circle, Colors.green),
    'RESERVA_PROXIMA': (Icons.event, colorPrimario),
    'INSCRIPCION_TORNEO': (Icons.emoji_events, Colors.purple),
    'INSCRIPCION_CLASE': (Icons.school, Colors.teal),
    'TORNEO_ABIERTO': (Icons.campaign, Colors.deepOrange),
  };

  Widget _tarjetaNovedad(Novedad n) {
    final (icono, color) = _iconos[n.tipo] ?? (Icons.notifications, colorPrimario);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: IconoCaja(icono, color: color),
        title: Text(n.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        // Los torneos duran días: se muestra solo la fecha de inicio
        subtitle: Text('${n.detalle} · ${n.tipo.contains('TORNEO') ? formatoDiaCorto(n.fecha) : formatoDiaHora(n.fecha)}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => _abrirNovedad(n),
      ),
    );
  }
}
