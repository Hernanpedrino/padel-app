import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/partido.dart';
import '../models/perfil.dart';
import '../providers/auth_provider.dart';
import '../services/partido_service.dart';
import '../utils/errores.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';

class PartidoDetalleScreen extends StatefulWidget {
  final String partidoId;
  const PartidoDetalleScreen({super.key, required this.partidoId});

  @override
  State<PartidoDetalleScreen> createState() => _PartidoDetalleScreenState();
}

class _PartidoDetalleScreenState extends State<PartidoDetalleScreen> {
  final PartidoService _service = PartidoService();
  Partido? _partido;
  bool _loading = true;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final partido = await _service.detalle(widget.partidoId);
      if (mounted) setState(() => _partido = partido);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Ejecuta una acción, muestra el resultado y recarga el partido
  Future<void> _accion(Future<void> Function() fn, String mensajeOk) async {
    setState(() => _procesando = true);
    try {
      await fn();
      if (!mounted) return;
      mostrarOk(context, mensajeOk);
      await _cargar();
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<bool> _confirmar(String titulo, String texto) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<AuthProvider>().perfil;
    final p = _partido;

    return Scaffold(
      appBar: barraApp('Partido'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : p == null
              ? const Vacio(icono: Icons.error_outline, texto: 'No se pudo cargar el partido.')
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _resumen(p),
                      const SizedBox(height: 16),
                      _jugadores(p, perfil),
                      const SizedBox(height: 16),
                      if (perfil != null) _acciones(p, perfil),
                    ],
                  ),
                ),
    );
  }

  Widget _resumen(Partido p) {
    final inicio = p.turno.fechaHoraInicio;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${etiquetaCategoria(p.categoria)} · ${etiquetaRama(p.rama)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                EstadoChip(p.estado),
              ],
            ),
            const SizedBox(height: 12),
            _dato(Icons.event, '${formatoDia(inicio)} · ${formatoHora(inicio)} a ${formatoHora(p.turno.fechaHoraFin)}'),
            _dato(Icons.place, '${p.complejoNombre} · ${p.turno.cancha.nombre}'),
            _dato(Icons.map_outlined, p.complejoDireccion),
            if (p.estado == 'ABIERTO')
              _dato(Icons.person_search, p.cuposLibres == 1 ? 'Falta 1 jugador' : 'Faltan ${p.cuposLibres} jugadores'),
            if (p.descripcion != null && p.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(p.descripcion!, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dato(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icono, size: 18, color: colorPrimario),
        const SizedBox(width: 8),
        Expanded(child: Text(texto)),
      ]),
    );
  }

  Widget _jugadores(Partido p, Perfil? perfil) {
    final esCreador = perfil?.id == p.creador.id;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('Jugadores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            _filaJugador(p.creador, 'Organiza'),
            ...p.aceptados.map((s) => _filaJugador(s.usuario, 'Confirmado')),
            if (esCreador)
              ...p.pendientes.map((s) => _filaJugador(
                    s.usuario,
                    'Quiere sumarse',
                    acciones: p.estado == 'ABIERTO'
                        ? Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              tooltip: 'Aceptar',
                              onPressed: _procesando
                                  ? null
                                  : () => _accion(() => _service.responder(p.id, s.id, aceptar: true),
                                      '${s.usuario.nombre} ya está en el partido'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              tooltip: 'Rechazar',
                              onPressed: _procesando
                                  ? null
                                  : () => _accion(() => _service.responder(p.id, s.id, aceptar: false), 'Solicitud rechazada'),
                            ),
                          ])
                        : null,
                  ))
            else if (p.pendientes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  p.pendientes.length == 1 ? '1 solicitud pendiente' : '${p.pendientes.length} solicitudes pendientes',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filaJugador(Jugador j, String rol, {Widget? acciones}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorPrimario.withValues(alpha: 0.1),
        child: Text(j.nombre[0], style: const TextStyle(color: colorPrimario)),
      ),
      title: Text(j.nombreCompleto),
      subtitle: Text('$rol · ${etiquetaCategoria(j.categoria)}'),
      trailing: acciones,
    );
  }

  Widget _acciones(Partido p, Perfil perfil) {
    final esCreador = perfil.id == p.creador.id;
    final solicitud = p.solicitudDe(perfil.id);
    final activo = p.estado == 'ABIERTO' || p.estado == 'COMPLETO';
    final yaPaso = p.turno.fechaHoraInicio.isBefore(DateTime.now());
    if (!activo || yaPaso) return const SizedBox.shrink();

    Widget boton(String texto, VoidCallback onPressed, {bool peligro = false}) => SizedBox(
          height: 48,
          child: peligro
              ? OutlinedButton(
                  onPressed: _procesando ? null : onPressed,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(texto),
                )
              : ElevatedButton(
                  onPressed: _procesando ? null : onPressed,
                  style: ElevatedButton.styleFrom(backgroundColor: colorPrimario, foregroundColor: Colors.white),
                  child: Text(texto),
                ),
        );

    if (esCreador) {
      return boton('Cancelar partido', () async {
        if (await _confirmar('Cancelar partido', 'Los jugadores anotados lo van a ver cancelado. Tu reserva de la cancha sigue vigente.')) {
          _accion(() => _service.cancelar(p.id), 'Partido cancelado');
        }
      }, peligro: true);
    }
    if (solicitud == null) {
      if (p.estado != 'ABIERTO') return const SizedBox.shrink();
      if (!perfil.completo) {
        return const Text('Completá tu categoría y género en el perfil para sumarte a partidos.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.orange));
      }
      return boton('Quiero sumarme', () => _accion(() => _service.pedirSumarse(p.id),
          'Solicitud enviada. Te avisamos cuando ${p.creador.nombre} responda.'));
    }
    final aceptado = solicitud.estado == 'ACEPTADA';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          aceptado ? '¡Estás confirmado en este partido!' : 'Tu solicitud está pendiente de respuesta.',
          textAlign: TextAlign.center,
          style: TextStyle(color: aceptado ? Colors.green : Colors.orange, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        boton(aceptado ? 'Bajarme del partido' : 'Retirar solicitud', () async {
          if (await _confirmar(aceptado ? 'Bajarte del partido' : 'Retirar solicitud', '¿Seguro?')) {
            _accion(() => _service.salir(p.id), aceptado ? 'Te bajaste del partido' : 'Solicitud retirada');
          }
        }, peligro: true),
      ],
    );
  }
}
